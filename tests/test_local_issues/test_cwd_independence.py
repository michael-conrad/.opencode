# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-02 (issue 2432, item 2): local-issues identity/discovery is CWD-independent.

Resolving the same qualifier (e.g. `.opencode#N`) MUST produce identical
`_resolve_repo_name()` and `_discover_all_repos()` results regardless of
whether the tool is invoked from the project root or a nested subdirectory.
Discovery must root at the tool's PROJECT_DIR with children coming
exclusively from .gitmodules entries. Currently both functions derive from
`os.getcwd()`, so the nested-CWD resolution differs and this test FAILS.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import importlib.util
import json
import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"
PROJECT_ROOT = Path(__file__).resolve().parents[3]  # .../opencode-config
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "issue-2432" / "test-sandboxes"

ROOT_REPO_NAME = "opencode-config"
CHILD_REPO_NAME = ".opencode"
ISSUE_NUMBER = "2432"


def _driver_source() -> str:
    """Driver script that loads the tool module and dumps identity/discovery."""
    return f"""
import importlib.util, json, sys
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("local_issues", sys.argv[1])
spec = importlib.util.spec_from_loader("local_issues", loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)
print(json.dumps({{
    "project_dir": str(mod.PROJECT_DIR),
    "repo_name": mod._resolve_repo_name(),
    "repos": [str(p) for p in mod._discover_all_repos()],
}}))
"""


@pytest.fixture
def sandbox() -> Path:
    """Isolated sandbox mirroring the real repo layout.

    <root>/opencode-config/
      .gitmodules            -> submodule ".opencode" path .opencode
      .opencode/             -> child git repo with .issues/2432/issue.yaml
      .opencode/tools/local-issues  (copy of the real tool)
      docs/                  -> nested non-repo directory (second CWD)
    """
    base = TMP_DIR / "run-2432-cwd"
    if base.exists():
        shutil.rmtree(base)
    root = base / ROOT_REPO_NAME
    tools_dir = root / ".opencode" / "tools"
    child_issues = root / CHILD_REPO_NAME / ".issues" / ISSUE_NUMBER
    nested_dir = root / "docs"
    tools_dir.mkdir(parents=True)
    child_issues.mkdir(parents=True)
    nested_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    (child_issues / "issue.yaml").write_text(
        "title: fixture\nlabels: []\ncreated: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )
    (root / ".gitmodules").write_text(
        f'[submodule "{CHILD_REPO_NAME}"]\n\tpath = {CHILD_REPO_NAME}\n',
        encoding="utf-8",
    )
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    subprocess.run(["git", "init", "-q", str(root / CHILD_REPO_NAME)], check=True)
    driver = base / "driver.py"
    driver.write_text(_driver_source(), encoding="utf-8")
    return root


def _probe(sandbox: Path, cwd: Path) -> dict:
    driver = sandbox.parent / "driver.py"
    tool = sandbox / ".opencode" / "tools" / TOOL_NAME
    result = subprocess.run(
        ["uv", "run", "--with", "pyyaml~=6.0", "python", str(driver), str(tool)],
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=120,
    )
    assert result.returncode == 0, f"driver failed: {result.stderr!r}"
    return json.loads(result.stdout)


def test_identity_and_discovery_identical_from_two_cwds(sandbox: Path) -> None:
    # SC-02: same qualifier resolved from project root vs nested subdirectory
    # must yield identical repo identity and discovery results.
    from_root = _probe(sandbox, sandbox)
    from_nested = _probe(sandbox, sandbox / "docs")

    assert from_root["project_dir"] == str(sandbox), (
        f"PROJECT_DIR must root at the project, got {from_root['project_dir']!r}"
    )

    # Identity: _resolve_repo_name() is CWD-independent -> always the root repo
    assert from_root["repo_name"] == ROOT_REPO_NAME, (
        f"root CWD identity wrong: {from_root['repo_name']!r}"
    )
    assert from_nested["repo_name"] == from_root["repo_name"], (
        f"CWD-derived identity: nested CWD resolved {from_nested['repo_name']!r}, "
        f"root CWD resolved {from_root['repo_name']!r}"
    )

    # Discovery: roots at PROJECT_DIR, children exclusively from .gitmodules
    expected_repos = [str(sandbox), str(sandbox / CHILD_REPO_NAME)]
    assert from_root["repos"] == expected_repos, (
        f"root CWD discovery wrong: {from_root['repos']!r}"
    )
    assert from_nested["repos"] == from_root["repos"], (
        f"CWD-derived discovery: nested CWD discovered {from_nested['repos']!r}, "
        f"root CWD discovered {from_root['repos']!r}"
    )


def test_nested_cwd_resolves_gitmodules_child(sandbox: Path) -> None:
    # SC-02: from a nested subdirectory the .gitmodules child repo must still
    # be discovered (discovery must not be limited to the CWD subtree).
    from_nested = _probe(sandbox, sandbox / "docs")
    assert str(sandbox / CHILD_REPO_NAME) in from_nested["repos"], (
        f"nested CWD discovery missing .gitmodules child: {from_nested['repos']!r}"
    )

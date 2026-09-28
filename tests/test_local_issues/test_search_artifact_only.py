# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-2 (issue 2449, phase 2): search marks yaml-less dirs [artifact-only].

Fixture tree contains one issue directory holding only spec.md (no
issue.yaml). `search` with a matching query MUST render that entry with
status `[artifact-only]` and MUST NOT synthesize `status: open` for it.
Current tool defect: the SC-2 path `_read_issue_data_in_repo` sets
`result["issue"] = {"body": ..., "status": "open"}` for yaml-less dirs,
and `_search_in_repo` defaults missing status to "open", so search
renders `#N [open]` for artifact-only directories.

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

# SC-2 artifact-only directory: spec.md only, no issue.yaml. The spec
# body contains a unique marker word used as the search query.
ARTIFACT_ONLY_NUM = 9977
MARKER = "sc2searchmarker"

QUERY = MARKER


def _find_project_root() -> Path:
    path = Path(__file__).resolve()
    while path.name != ".opencode":
        if path.parent == path:
            raise RuntimeError("Could not find .opencode/ directory")
        path = path.parent
    return path.parent


PROJECT_ROOT = _find_project_root()
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "2449" / "test-sandboxes"


@pytest.fixture
def sandbox() -> Path:
    """Isolated sandbox repo with a copy of local-issues and a fixture tree.

    Layout mirrors the real repo: <root>/opencode-config/.opencode/tools/
    local-issues plus .issues/{N}/ fixture issues. One issue holds only
    spec.md containing the search marker (artifact-only, no issue.yaml);
    one issue holds a valid issue.yaml with the same marker and must
    still render [open].
    """
    base = TMP_DIR / "run-sc2"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)

    # Artifact-only issue: spec.md only, no issue.yaml (SC-2 fixture).
    # Body text contains the marker so `search <marker>` matches it.
    artifact_only = issues_dir / str(ARTIFACT_ONLY_NUM)
    artifact_only.mkdir(parents=True)
    (artifact_only / "spec.md").write_text(
        f"Artifact-only issue mentioning {MARKER} in a plain markdown "
        "body with no frontmatter.\n",
        encoding="utf-8",
    )

    # Control issue: valid issue.yaml, must still render [open].
    valid = issues_dir / "9976"
    valid.mkdir()
    (valid / "issue.yaml").write_text(
        "title: valid-open-issue with sc2searchmarker\n"
        "status: open\n"
        "labels: []\n"
        "created: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )
    (valid / "spec.md").write_text(
        f"Valid issue body also containing {MARKER} for search.\n",
        encoding="utf-8",
    )

    subprocess.run(["git", "init", "-q", str(root)], check=True)
    return root


def _run_tool(sandbox: Path, *cli_args: str) -> subprocess.CompletedProcess:
    tool = sandbox / ".opencode" / "tools" / TOOL_NAME
    return subprocess.run(
        ["uv", "run", "--script", str(tool), *cli_args],
        cwd=sandbox,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,
    )


def test_search_artifact_only_status(sandbox: Path) -> None:
    # SC-2: search renders the yaml-less dir as [artifact-only], not [open].
    result = _run_tool(sandbox, "search", "--query", QUERY)
    display = f"opencode-config#{ARTIFACT_ONLY_NUM}"
    assert result.returncode == 0, (
        f"search crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    artifact_entry = next(
        (line for line in result.stdout.splitlines() if display in line),
        None,
    )
    assert artifact_entry is not None, (
        f"search output missing entry for {display}: {result.stdout!r}"
    )
    assert "[artifact-only]" in artifact_entry, (
        f"SC-2 RED: yaml-less dir rendered without [artifact-only] status; "
        f"entry: {artifact_entry!r}"
    )
    assert "[open]" not in artifact_entry, (
        f"SC-2 RED: yaml-less dir rendered with synthesized [open] status; "
        f"entry: {artifact_entry!r}"
    )


def test_search_control_issue_still_open(sandbox: Path) -> None:
    # SC-2: control issue with valid issue.yaml still renders [open].
    result = _run_tool(sandbox, "search", "--query", QUERY)
    assert result.returncode == 0, (
        f"search crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    control_entry = next(
        (line for line in result.stdout.splitlines() if "opencode-config#9976" in line),
        None,
    )
    assert control_entry is not None, (
        f"search output missing control entry: {result.stdout!r}"
    )
    assert "[open]" in control_entry, (
        f"control issue lost [open] status: {control_entry!r}"
    )

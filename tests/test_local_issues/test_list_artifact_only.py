# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-1 (issue 2449, phase 1): list emits [artifact-only] for yaml-less dirs.

Fixture tree contains one issue directory holding only spec.md (no
issue.yaml). `list` MUST render that entry with status
`[artifact-only]` and MUST NOT render `[open]` for it. Current tool
defect: yaml-less dirs render `#N [open]` because
`_read_issue_title_status` defaults status to "open" when issue.yaml is
missing.

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

# SC-1 artifact-only directory: spec.md only, no issue.yaml.
ARTIFACT_ONLY_NUM = 9999


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
    spec.md (artifact-only, no issue.yaml); one issue holds a valid
    issue.yaml and must still render [open].
    """
    base = TMP_DIR / "run-sc1"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)

    # Artifact-only issue: spec.md only, no issue.yaml (SC-1 fixture).
    artifact_only = issues_dir / str(ARTIFACT_ONLY_NUM)
    artifact_only.mkdir(parents=True)
    (artifact_only / "spec.md").write_text(
        "Artifact-only issue with plain markdown body, no frontmatter.\n",
        encoding="utf-8",
    )

    # Control issue: valid issue.yaml, must still render [open].
    valid = issues_dir / "9998"
    valid.mkdir()
    (valid / "issue.yaml").write_text(
        "title: valid-open-issue\n"
        "status: open\n"
        "labels: []\n"
        "created: '2026-01-01T00:00:00Z'\n",
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


def test_list_artifact_only_status(sandbox: Path) -> None:
    # SC-1: list renders the yaml-less dir as [artifact-only], not [open].
    result = _run_tool(sandbox, "list")
    display = f"opencode-config#{ARTIFACT_ONLY_NUM}"
    assert result.returncode == 0, (
        f"list crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    artifact_entry = next(
        (line for line in result.stdout.splitlines() if display in line),
        None,
    )
    assert artifact_entry is not None, (
        f"list output missing entry for {display}: {result.stdout!r}"
    )
    assert "[artifact-only]" in artifact_entry, (
        f"SC-1 RED: yaml-less dir rendered without [artifact-only] status; "
        f"entry: {artifact_entry!r}"
    )
    assert "[open]" not in artifact_entry, (
        f"SC-1 RED: yaml-less dir rendered with [open] status; "
        f"entry: {artifact_entry!r}"
    )


def test_list_control_issue_still_open(sandbox: Path) -> None:
    # SC-1: control issue with valid issue.yaml still renders [open].
    result = _run_tool(sandbox, "list")
    assert result.returncode == 0, (
        f"list crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    control_entry = next(
        (line for line in result.stdout.splitlines() if "opencode-config#9998" in line),
        None,
    )
    assert control_entry is not None, (
        f"list output missing control entry: {result.stdout!r}"
    )
    assert "[open]" in control_entry, (
        f"control issue lost [open] status: {control_entry!r}"
    )

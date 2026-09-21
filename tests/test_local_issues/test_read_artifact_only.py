# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-3 (issue 2449, phase 3): read omits status for yaml-less dirs.

Fixture tree contains one issue directory holding only spec.md (no
issue.yaml). `read` on that number MUST NOT report a status line at all
— in particular it MUST NOT fabricate `status: open` (SC-3 literal).
Current tool defect: the read path prints `status: artifact-only` for
yaml-less dirs because `_read_issue_data_in_repo` synthesizes a status
key and `cmd_read` dumps the issue dict verbatim — the sentinel must be
consumed by read output formatting so no status line is rendered.

Control: an issue with a well-formed `issue.yaml` MUST still report its
real `status: open` — SC-4 preservation is phase 4's concern, this
control only guards the read path against over-suppression.

Runs against an isolated sandbox copy of the tool so no real
`.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

# SC-3 artifact-only directory: spec.md only, no issue.yaml.
ARTIFACT_ONLY_NUM = 9979
# Control issue: valid issue.yaml with real status.
CONTROL_NUM = 9978

STATUS_LINE_PREFIX = "  status:"


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
    issue.yaml and must still report its real status.
    """
    base = TMP_DIR / "run-sc3"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    issues_dir = root / ".issues"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)

    # Artifact-only issue: spec.md only, no issue.yaml (SC-3 fixture).
    artifact_only = issues_dir / str(ARTIFACT_ONLY_NUM)
    artifact_only.mkdir(parents=True)
    (artifact_only / "spec.md").write_text(
        "Artifact-only issue with a plain markdown body and no "
        "frontmatter.\n",
        encoding="utf-8",
    )

    # Control issue: valid issue.yaml with a real status: open.
    valid = issues_dir / str(CONTROL_NUM)
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


def _issue_block(stdout: str, display: str) -> str:
    """Return the issue: block of a single-issue read output."""
    lines = stdout.splitlines()
    start = next(i for i, ln in enumerate(lines) if ln == "issue:")
    return "\n".join(lines[start:])


def test_read_artifact_only_omits_status(sandbox: Path) -> None:
    # SC-3: read on the yaml-less dir renders NO status line — neither
    # the fabricated `status: open` nor the artifact-only sentinel.
    result = _run_tool(
        sandbox, "read", "--number", f"opencode-config#{ARTIFACT_ONLY_NUM}"
    )
    assert result.returncode == 0, (
        f"read crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    block = _issue_block(result.stdout, f"opencode-config#{ARTIFACT_ONLY_NUM}")
    status_lines = [
        ln for ln in block.splitlines() if ln.startswith(STATUS_LINE_PREFIX)
    ]
    assert status_lines == [], (
        f"SC-3 RED: read fabricates a status line for a yaml-less dir; "
        f"status line(s): {status_lines!r}; output: {result.stdout!r}"
    )
    assert "status: open" not in block, (
        f"SC-3 RED: read fabricates `status: open` for a yaml-less dir; "
        f"output: {result.stdout!r}"
    )


def test_read_control_issue_keeps_status(sandbox: Path) -> None:
    # Control: read on a well-formed issue still reports its real status.
    result = _run_tool(
        sandbox, "read", "--number", f"opencode-config#{CONTROL_NUM}"
    )
    assert result.returncode == 0, (
        f"read crashed (exit {result.returncode}); stderr: {result.stderr!r}"
    )
    block = _issue_block(result.stdout, f"opencode-config#{CONTROL_NUM}")
    assert "status: open" in block, (
        f"control issue lost its real status: open; output: {result.stdout!r}"
    )

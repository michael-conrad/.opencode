# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""RED (issue 2672): re-opening via update leaves closed-state residue.

`close` writes `status: closed`, `closed_at`, `close_reason` (and
`duplicate_of` for duplicate closures). Re-opening through the only
tool-mediated path — `update --status open` — must clear those closed-state
fields; otherwise the store record contradicts itself (`status: open` while
`closed_at`/`close_reason` remain). Closing-again behavior is unchanged:
`update --status closed` keeps closing semantics it already had.

Runs against an isolated sandbox issues worktree, never the live worktree.

The test fails at RED because `cmd_update` never touches the closed-state
fields.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

GITMODULES = (
    '[submodule ".opencode"]\n'
    "\tpath = .opencode\n"
    "\turl = https://example.invalid/michael-conrad/.opencode.git\n"
)
TMP_DIR = Path(__file__).resolve().parents[3] / "tmp" / "issue-2672" / "test-sandboxes"


def _real_tool() -> Path:
    base = Path(__file__).resolve()
    while base.name != ".opencode":
        if base.parent == base:
            raise RuntimeError("Could not find .opencode/ directory")
        base = base.parent
    return base / "tools" / TOOL_NAME


REAL_TOOL = _real_tool()


def _write_fake_worktree_gitlink(issues_dir: Path) -> None:
    """Mark .issues/ as an active worktree so bootstrap machinery skips."""
    (issues_dir / ".git").write_text(
        "gitdir: /nonexistent/issues-worktree/.git/worktrees/-issues\n",
        encoding="utf-8",
    )


@pytest.fixture
def sandbox() -> Path:
    base = TMP_DIR / "run-update-reopen"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    root_issues = root / ".issues"
    child_issues = root / ".opencode" / ".issues"
    tools_dir.mkdir(parents=True)
    root_issues.mkdir(parents=True)
    child_issues.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    (root / ".gitmodules").write_text(GITMODULES, encoding="utf-8")
    _write_fake_worktree_gitlink(root_issues)
    _write_fake_worktree_gitlink(child_issues)
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


def _make_closed_issue(sandbox: Path, *close_args: str) -> Path:
    result = _run_tool(
        sandbox, "create", "--number", "opencode-config#1", "--title", "target issue"
    )
    assert result.returncode == 0, (
        f"sandbox create failed unexpectedly; stderr: {result.stderr!r}"
    )
    result = _run_tool(sandbox, "close", "--number", "opencode-config#1", *close_args)
    assert result.returncode == 0, (
        f"sandbox close failed unexpectedly; stderr: {result.stderr!r}"
    )
    return sandbox / ".issues" / "1" / "issue.yaml"


def _load_yaml(path: Path) -> dict:
    import sys

    sys.path.insert(0, str(path.parent))
    try:
        import yaml

        return yaml.safe_load(path.read_text(encoding="utf-8"))
    finally:
        sys.path.pop(0)


def test_update_status_open_clears_closed_state(sandbox: Path) -> None:
    path = _make_closed_issue(sandbox, "--reason", "completed")
    closed = _load_yaml(path)
    assert closed["status"] == "closed"
    assert "closed_at" in closed and "close_reason" in closed

    result = _run_tool(
        sandbox, "update", "--number", "opencode-config#1", "--status", "open"
    )
    assert result.returncode == 0, f"update failed; stderr: {result.stderr!r}"

    reopened = _load_yaml(path)
    assert reopened["status"] == "open"
    assert "closed_at" not in reopened, (
        f"update --status open left stale closed_at; record: {reopened!r}"
    )
    assert "close_reason" not in reopened, (
        f"update --status open left stale close_reason; record: {reopened!r}"
    )


def test_update_status_open_clears_duplicate_of(sandbox: Path) -> None:
    path = _make_closed_issue(
        sandbox,
        "--reason",
        "duplicate",
        "--duplicate-of",
        "2",
    )
    closed = _load_yaml(path)
    assert closed["status"] == "closed"
    assert "duplicate_of" in closed, f"expected duplicate_of; record: {closed!r}"

    result = _run_tool(
        sandbox, "update", "--number", "opencode-config#1", "--status", "open"
    )
    assert result.returncode == 0, f"update failed; stderr: {result.stderr!r}"

    reopened = _load_yaml(path)
    assert reopened["status"] == "open"
    assert "duplicate_of" not in reopened, (
        f"update --status open left stale duplicate_of; record: {reopened!r}"
    )


def test_update_other_fields_does_not_resurrect_closed_state(sandbox: Path) -> None:
    """A non-status update on a closed issue must not strip closed-state fields."""
    path = _make_closed_issue(sandbox, "--reason", "completed")

    result = _run_tool(
        sandbox, "update", "--number", "opencode-config#1", "--title", "renamed"
    )
    assert result.returncode == 0, f"update failed; stderr: {result.stderr!r}"

    updated = _load_yaml(path)
    assert updated["status"] == "closed"
    assert "closed_at" in updated and "close_reason" in updated


if __name__ == "__main__":
    import sys

    sys.exit(pytest.main([__file__]))
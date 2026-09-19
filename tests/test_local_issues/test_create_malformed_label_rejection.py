# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""RED (issue 2446, item 13, SC-2b): create rejects malformed label tokens.

`create` invoked with a label token that still contains whitespace after
normalization (e.g. `'a b'` — normalization can split on commas and strip
outer whitespace, but the inner space is unresolvable) MUST exit with a
CLI error before any file write or auto-commit, and MUST NOT create the
target `issue.yaml`.

The spec requires rejecting structurally malformed input; normalization
alone is insufficient. Runs against an isolated sandbox issues worktree,
never the live worktree.

The test fails at RED because malformed-remainder rejection does not
exist yet in `cmd_create`.

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
TMP_DIR = Path(__file__).resolve().parents[3] / "tmp" / "issue-2446" / "test-sandboxes"


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
    base = TMP_DIR / "run-create-malformed-label"
    if base.exists():
        shutil.rmtree(base)
    root = base / "opencode-config"
    tools_dir = root / ".opencode" / "tools"
    child_issues = root / ".opencode" / ".issues"
    tools_dir.mkdir(parents=True)
    child_issues.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    (root / ".gitmodules").write_text(GITMODULES, encoding="utf-8")
    (child_issues / ".counter").write_text("10\n", encoding="utf-8")
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


def _issue_yaml(sandbox: Path) -> Path:
    return sandbox / ".issues" / "1" / "issue.yaml"


def test_create_malformed_label_token_exits_with_error(sandbox: Path) -> None:
    result = _run_tool(
        sandbox,
        "create",
        "--number",
        "opencode-config#1",
        "--title",
        "target issue",
        "--labels",
        "a b",
    )
    assert result.returncode != 0, (
        "create accepted a malformed label token 'a b' (inner whitespace "
        "unresolvable by normalization); expected nonzero exit; "
        f"stdout: {result.stdout!r}"
    )


def test_create_malformed_label_token_does_not_create_issue_yaml(
    sandbox: Path,
) -> None:
    result = _run_tool(
        sandbox,
        "create",
        "--number",
        "opencode-config#1",
        "--title",
        "target issue",
        "--labels",
        "a b",
    )
    path = _issue_yaml(sandbox)
    assert not path.is_file(), (
        "issue.yaml was created despite a rejected malformed-label create; "
        f"stderr: {result.stderr!r}"
    )


if __name__ == "__main__":
    import sys

    sys.exit(pytest.main([__file__]))

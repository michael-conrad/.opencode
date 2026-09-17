# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-04 (issue 2432, item 4): create counter targeting via qualifier.

`create` invoked with the `.opencode` qualifier MUST increment the
`.opencode` repo's `.issues/.counter` and leave the root repo counter
byte-identical. Fail-fast semantics preserved: missing counter creates
at 1; corrupt counter exits FATAL. Runs against an isolated sandbox so
no real `.issues/` state is touched.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"

ROOT_COUNTER_INITIAL = "5\n"
CHILD_COUNTER_INITIAL = "10\n"
GITMODULES = (
    '[submodule ".opencode"]\n'
    "\tpath = .opencode\n"
    "\turl = https://example.invalid/michael-conrad/.opencode.git\n"
)
TMP_DIR = Path(__file__).resolve().parents[3] / "tmp" / "issue-2432" / "test-sandboxes"


def _real_tool() -> Path:
    base = Path(__file__).resolve()
    while base.name != ".opencode":
        if base.parent == base:
            raise RuntimeError("Could not find .opencode/ directory")
        base = base.parent
    return base / "tools" / TOOL_NAME


REAL_TOOL = _real_tool()


def _write_fake_worktree_gitlink(issues_dir: Path) -> None:
    """Mark .issues/ as an active worktree so bootstrap machinery skips.

    `_worktree_active` returns True when `<root>/.issues/.git` is a file.
    The fake gitlink points at a nonexistent gitdir, so auto-commit/push
    degrade to stderr warnings instead of mutating state.
    """
    (issues_dir / ".git").write_text(
        "gitdir: /nonexistent/issues-worktree/.git/worktrees/-issues\n",
        encoding="utf-8",
    )


@pytest.fixture
def sandbox() -> Path:
    base = TMP_DIR / "run-counter-targeting"
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
    (root_issues / ".counter").write_text(ROOT_COUNTER_INITIAL, encoding="utf-8")
    (child_issues / ".counter").write_text(CHILD_COUNTER_INITIAL, encoding="utf-8")
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


def _read_bytes(path: Path) -> bytes:
    return path.read_bytes()


def test_create_opencode_qualifier_increments_child_counter(sandbox: Path) -> None:
    # SC-04: create with .opencode qualifier increments the .opencode counter
    result = _run_tool(
        sandbox, "create", "--number", ".opencode#11", "--title", "counter targeting"
    )
    assert result.returncode == 0, (
        f"create .opencode#11 failed unexpectedly; stderr: {result.stderr!r}"
    )
    child_counter = sandbox / ".opencode" / ".issues" / ".counter"
    assert child_counter.read_text(encoding="utf-8") == "11\n", (
        f".opencode counter was not incremented by the create; "
        f"expected '11\\n', got {child_counter.read_text(encoding='utf-8')!r}; "
        f"stderr: {result.stderr!r}"
    )


def test_root_counter_byte_identical_after_child_create(sandbox: Path) -> None:
    # SC-04: root counter must be byte-identical (unchanged) after the create
    root_counter = sandbox / ".issues" / ".counter"
    before = _read_bytes(root_counter)
    result = _run_tool(
        sandbox, "create", "--number", ".opencode#11", "--title", "counter targeting"
    )
    assert result.returncode == 0, (
        f"create .opencode#11 failed unexpectedly; stderr: {result.stderr!r}"
    )
    assert _read_bytes(root_counter) == before, (
        "root repo .issues/.counter changed during a .opencode-qualified create — "
        "counter writes are leaking across repos"
    )


def test_missing_counter_creates_at_1(sandbox: Path) -> None:
    # SC-04 fail-fast semantics: missing counter creates at 1
    child_counter = sandbox / ".opencode" / ".issues" / ".counter"
    child_counter.unlink()
    result = _run_tool(
        sandbox, "create", "--number", ".opencode#1", "--title", "missing counter"
    )
    assert result.returncode == 0, (
        f"create with missing counter failed; stderr: {result.stderr!r}"
    )
    assert child_counter.exists(), (
        "missing counter was not created during .opencode-qualified create"
    )
    assert child_counter.read_text(encoding="utf-8") == "1\n", (
        f"missing counter should be created at 1; got "
        f"{child_counter.read_text(encoding='utf-8')!r}"
    )


def test_corrupt_counter_fails_fast(sandbox: Path) -> None:
    # SC-04 fail-fast semantics: corrupt counter exits FATAL
    child_counter = sandbox / ".opencode" / ".issues" / ".counter"
    child_counter.write_text("not-a-number\n", encoding="utf-8")
    result = _run_tool(
        sandbox, "create", "--number", ".opencode#11", "--title", "corrupt counter"
    )
    assert result.returncode != 0, (
        f"create with corrupt counter exited 0 (fail-fast lost); "
        f"stderr: {result.stderr!r}"
    )
    assert "FATAL" in result.stderr, (
        f"corrupt counter error missing FATAL marker: {result.stderr!r}"
    )

# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-08 (issue 2432, item 8): doctor branch-health marker for missing issues-data branch.

The `doctor` subcommand emits per-repo health markers (branch state,
merge-base delta vs origin/issues-data, counter state, worktree
presence) for the root and all discovered repos. It is read-only — it
never mutates state.

This test builds a sandbox repo whose `.issues/` worktree exists but
whose local `issues-data` branch is missing, then invokes `doctor` and
asserts an unhealthy branch marker is emitted for that repo
(machine-greppable). While the `doctor` subcommand does not exist, the
tool exits non-zero (argparse unrecognized-subcommand failure) and the
assertion cannot be satisfied — RED.

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
TMP_DIR = Path(__file__).resolve().parents[3] / "tmp" / "issue-2432" / "test-sandboxes"

# Machine-greppable marker expectation: an unhealthy branch-state marker
# must name the repo and carry the UNHEALTHY marker token.
UNHEALTHY_TOKEN = "UNHEALTHY"


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
    The fake gitlink points at a nonexistent gitdir, so any mutation
    paths degrade to stderr warnings instead of mutating state. `doctor`
    must be read-only regardless.
    """
    (issues_dir / ".git").write_text(
        "gitdir: /nonexistent/issues-worktree/.git/worktrees/-issues\n",
        encoding="utf-8",
    )


@pytest.fixture
def sandbox() -> Path:
    """Sandbox repo whose local issues-data branch is missing.

    The fixture repo has NO local `issues-data` branch (a fresh `git
    init` creates only the default branch), which is exactly the
    unhealthy branch state SC-08 requires doctor to detect.
    """
    base = TMP_DIR / "run-doctor-branch-health"
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
    # Sanity: confirm the local issues-data branch really is absent.
    branches = subprocess.run(
        ["git", "branch", "--list", "issues-data"],
        cwd=root,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    assert "issues-data" not in branches, (
        "fixture setup error: sandbox unexpectedly has a local issues-data branch"
    )
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


def test_doctor_reports_unhealthy_branch_for_repo_missing_issues_data(
    sandbox: Path,
) -> None:
    # SC-08: doctor emits a per-repo unhealthy branch marker when the
    # local issues-data branch is missing.
    result = _run_tool(sandbox, "doctor")
    output = result.stdout + result.stderr
    assert result.returncode == 0, (
        f"doctor subcommand failed (exit {result.returncode}); "
        f"combined output: {output!r}"
    )
    assert UNHEALTHY_TOKEN in output, (
        f"doctor output missing {UNHEALTHY_TOKEN!r} marker despite missing "
        f"local issues-data branch; combined output: {output!r}"
    )
    # Per-repo marker: the unhealthy branch marker must be attributed to
    # at least one repo path (root `.issues` or `.opencode` child).
    assert ".issues" in output and ".opencode" in output, (
        "doctor output missing per-repo attribution (expected repo paths "
        "root .issues and .opencode); combined output: "
        f"{output!r}"
    )


def test_doctor_is_read_only(sandbox: Path) -> None:
    # SC-08: doctor never mutates state — the sandbox tree must be
    # byte-identical before and after the doctor invocation.
    before = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=sandbox,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    result = _run_tool(sandbox, "doctor")
    after = subprocess.run(
        ["git", "status", "--porcelain"],
        cwd=sandbox,
        capture_output=True,
        text=True,
        check=True,
    ).stdout
    assert before == after, (
        f"doctor mutated the repo state (git status changed): "
        f"before={before!r} after={after!r}; stderr: {result.stderr!r}"
    )

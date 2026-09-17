# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""SC-03 (issue 2432, item 3): bootstrap checks remote refs before orphaning.

When a sandbox repo holds `origin/issues-data` (remote-tracking branch
present) but NO local `issues-data` branch, the local-issues worktree
bootstrap MUST NOT create a fresh orphan branch. It must check out a
local `issues-data` branch that tracks the remote branch, with the local
branch tip equal to the remote `origin/issues-data` seed commit.

Currently `_issues_branch_exists()` checks only local refs
(`refs/heads/issues-data`), so the bootstrap path sees "no branch" and
creates an orphan — the local branch tip diverges from the remote seed
and this test FAILS (RED).

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

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
BRANCH = "issues-data"


def _git(*args: str, cwd: Path | None = None, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=30,
        check=False,
    )
    if check:
        assert result.returncode == 0, f"git {' '.join(args)} failed: {result.stderr!r}"
    return result.stdout.strip()


def _driver_source() -> str:
    """Driver script that loads the tool module and runs the bootstrap path."""
    return """
import importlib.util, json, sys
from importlib.machinery import SourceFileLoader
loader = SourceFileLoader("local_issues", sys.argv[1])
spec = importlib.util.spec_from_loader("local_issues", loader)
mod = importlib.util.module_from_spec(spec)
loader.exec_module(mod)
from pathlib import Path
repo = Path(sys.argv[2])
ok = mod._ensure_worktree(repo_path=repo)
active = mod._worktree_active(repo_path=repo)
local_exists = mod._issues_branch_exists(repo_path=repo)
print(json.dumps({
    "ensure_ok": ok,
    "worktree_active": active,
    "local_branch_exists": local_exists,
}))
"""


@pytest.fixture
def sandbox() -> Path:
    """Sandbox repo with origin/issues-data remote branch, no local branch.

    <base>/remote.git           bare "origin" holding the issues-data branch
    <base>/opencode-config/     clone root: origin set, fetched, NO local
                                issues-data branch, tool copied into
                                .opencode/tools/
    """
    base = TMP_DIR / "run-2432-sc03"
    if base.exists():
        shutil.rmtree(base)
    base.mkdir(parents=True)

    remote = base / "remote.git"
    _git("init", "--bare", "-q", str(remote))

    # Seed the remote's issues-data branch with one commit.
    seed = base / "seed"
    _git("init", "-q", str(seed))
    _git("config", "user.email", "test@example.com", cwd=seed)
    _git("config", "user.name", "test", cwd=seed)
    (seed / "issue.yaml").write_text(
        "title: seed\nlabels: []\ncreated: '2026-01-01T00:00:00Z'\n",
        encoding="utf-8",
    )
    _git("add", "-A", cwd=seed)
    _git("commit", "-q", "-m", "seed issues-data", cwd=seed)
    _git("branch", "-M", BRANCH, cwd=seed)
    _git("push", "-q", str(remote), BRANCH, cwd=seed)

    # Root clone: remote configured + fetched, but no local issues-data.
    root = base / ROOT_REPO_NAME
    _git("clone", "-q", str(remote), str(root))
    _git("checkout", "-q", "--detach", "origin/issues-data", cwd=root)
    _git(
        "branch", "-D", "-q", BRANCH, cwd=root, check=False
    )  # ensure NO local issues-data
    _git("config", "user.email", "test@example.com", cwd=root)
    _git("config", "user.name", "test", cwd=root)

    tools_dir = root / ".opencode" / "tools"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    (root / ".gitmodules").write_text(
        '[submodule ".opencode"]\n\tpath = .opencode\n', encoding="utf-8"
    )
    _git("add", "-A", cwd=root)
    _git("commit", "-q", "-m", "initial", cwd=root)

    # Preconditions: remote branch present, local branch absent.
    rc = subprocess.run(
        ["git", "rev-parse", "--verify", "-q", f"refs/heads/{BRANCH}"],
        cwd=root,
        capture_output=True,
        text=True,
        check=False,
    )
    assert rc.returncode != 0, "fixture bug: local issues-data branch must not exist"

    driver = base / "driver.py"
    driver.write_text(_driver_source(), encoding="utf-8")
    return root


def _probe(sandbox: Path) -> dict:
    driver = sandbox.parent / "driver.py"
    tool = sandbox / ".opencode" / "tools" / TOOL_NAME
    result = subprocess.run(
        [
            "uv",
            "run",
            "--with",
            "pyyaml~=6.0",
            "python",
            str(driver),
            str(tool),
            str(sandbox),
        ],
        cwd=sandbox,
        capture_output=True,
        text=True,
        timeout=120,
        check=False,
    )
    assert result.returncode == 0, f"driver failed: {result.stderr!r}"
    return json.loads(result.stdout)


def test_bootstrap_uses_remote_branch_no_orphan(sandbox: Path) -> None:
    # SC-03: bootstrap with remote-only issues-data must check out a
    # remote-tracked local branch, never create a fresh orphan branch.
    probe = _probe(sandbox)

    assert probe["ensure_ok"] is True, f"bootstrap failed: {probe!r}"
    assert probe["worktree_active"] is True, f"worktree not active: {probe!r}"
    assert probe["local_branch_exists"] is True, (
        f"local issues-data branch missing after bootstrap: {probe!r}"
    )

    # No orphan: local branch tip must equal the remote seed commit.
    local_sha = _git("rev-parse", f"refs/heads/{BRANCH}", cwd=sandbox)
    remote_sha = _git("rev-parse", f"refs/remotes/origin/{BRANCH}", cwd=sandbox)
    assert local_sha == remote_sha, (
        "ORPHAN CREATED: local issues-data tip "
        f"{local_sha} != origin/issues-data tip {remote_sha} — bootstrap "
        "ignored the remote branch and created a fresh orphan"
    )

    # Remote-tracked: the local branch must track origin/issues-data.
    upstream = _git("rev-parse", "--abbrev-ref", f"{BRANCH}@{{upstream}}", cwd=sandbox)
    assert upstream == f"origin/{BRANCH}", (
        f"local issues-data tracks {upstream!r}, expected 'origin/{BRANCH}'"
    )

    # The worktree checkout must be on the issues-data branch.
    checked_out = _git(
        "-C", str(sandbox / ".issues"), "rev-parse", "--abbrev-ref", "HEAD"
    )
    assert checked_out == BRANCH, (
        f".issues worktree on {checked_out!r}, expected {BRANCH!r}"
    )

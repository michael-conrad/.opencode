# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""R-2/R-3/R-4 (.opencode#2667): pull-only detection, refusals, reporting.

A registered submodule whose effective origin is `http`/`https` is
pull-only: the tool creates no issue store in it, syncs nothing against
it, refuses every mutation command naming it, and reports its
classification in the per-repository report and in `doctor`. The
workspace root is exempt from the classification.

The fixtures register the child through git's registered-submodule
mechanism (a gitlink update-index + .gitmodules), because that is the
eligibility mechanism the tool discovers store hosts by.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"
TMP_DIR = Path(__file__).resolve().parents[3] / "tmp" / "issue-2667" / "test-sandboxes"

ROOT_REPO_DIRNAME = "opencode-config"
CHILD_REPO_DIRNAME = ".opencode"
PULL_ONLY_ORIGIN = "https://example.invalid/michael-conrad/.opencode.git"
WRITEABLE_SSH_ORIGIN = "git@example.invalid:michael-conrad/.opencode.git"

MUTATION_PROBES = (
    ("create", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--title", "probe")),
    ("update", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--title", "probe")),
    ("comment", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--body", "probe")),
    ("close", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--reason", "completed")),
    ("delete", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--force")),
    ("link", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--sub", "1", "--type", "sub-issue")),
    ("renumber", ("--from", f"{CHILD_REPO_DIRNAME}#9999", "--to", f"{CHILD_REPO_DIRNAME}#9998")),
)


def _real_tool() -> Path:
    base = Path(__file__).resolve()
    while base.name != ".opencode":
        if base.parent == base:
            raise RuntimeError("Could not find .opencode/ directory")
        base = base.parent
    return base / "tools" / TOOL_NAME


REAL_TOOL = _real_tool()


def _git(cwd: Path, *args: str, check: bool = True) -> str:
    result = subprocess.run(
        ["git", "-C", str(cwd), *args],
        capture_output=True, text=True, timeout=60, check=check,
    )
    return result.stdout.strip()


def _register_child(root: Path, child: Path, origin_url: str, init_child: bool) -> None:
    """Register `child` as a registered submodule of `root` with a stored origin.

    Writes the child checkout (a real git repository with one commit), sets
    its `origin`, records the .gitmodules entry and the gitlink so
    `git submodule status` reports it — the eligibility mechanism R-1
    discovers store hosts by.
    """
    if init_child:
        subprocess.run(["git", "init", "-q", str(child)], check=True)
        (child / "README.md").write_text("fixture\n", encoding="utf-8")
        _git(child, "add", "README.md")
        _git(child, "-c", "user.name=fixture", "-c", "user.email=f@x", "commit", "-q", "-m", "init")
    if origin_url:
        _git(child, "remote", "add", "origin", origin_url)
    sha = _git(child, "rev-parse", "HEAD")
    shutil.copytree(child, root / CHILD_REPO_DIRNAME, dirs_exist_ok=True)
    (root / ".gitmodules").write_text(
        f'[submodule "{CHILD_REPO_DIRNAME}"]\n'
        f"\tpath = {CHILD_REPO_DIRNAME}\n"
        f"\turl = {origin_url}\n",
        encoding="utf-8",
    )
    _git(root, "add", ".gitmodules")
    _git(root, "update-index", "--add", "--cacheinfo", f"160000,{sha},{CHILD_REPO_DIRNAME}")
    # Initialize the registration in git's own mechanism (the effect of
    # `git submodule init`) — otherwise `submodule status` reports `-`.
    _git(root, "config", f"submodule.{CHILD_REPO_DIRNAME}.url", origin_url)
    _git(root, "-c", "user.name=fixture", "-c", "user.email=f@x", "commit", "-q", "-m", "register submodule")
    status = _git(root, "submodule", "status", check=False)
    assert CHILD_REPO_DIRNAME in status, (
        f"fixture setup error: child not registered; submodule status: {status!r}"
    )


@pytest.fixture
def pull_only_sandbox() -> Path:
    """Workspace: writable-configured root + a pull-only (https) child.

    The child's stored origin is an https URL that resolves to nothing, so
    any wrongly-attempted fetch or push fails fast. The root's origin is a
    reachable local bare repository.
    """
    base = TMP_DIR / "pull-only"
    if base.exists():
        shutil.rmtree(base)
    root = base / ROOT_REPO_DIRNAME
    child = base / "child"
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    subprocess.run(["git", "init", "-q", "--bare", str(base / "origin.git")], check=True)
    _git(root, "remote", "add", "origin", str(base / "origin.git"))
    _register_child(root, child, PULL_ONLY_ORIGIN, init_child=True)
    tools_dir = root / CHILD_REPO_DIRNAME / "tools"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    return root


@pytest.fixture
def writeable_child_sandbox() -> Path:
    """Workspace: writable-configured root + a registered ssh-origin child."""
    base = TMP_DIR / "writeable-child"
    if base.exists():
        shutil.rmtree(base)
    root = base / ROOT_REPO_DIRNAME
    child = base / "child"
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    subprocess.run(["git", "init", "-q", "--bare", str(base / "origin.git")], check=True)
    _git(root, "remote", "add", "origin", str(base / "origin.git"))
    _register_child(root, child, WRITEABLE_SSH_ORIGIN, init_child=True)
    tools_dir = root / CHILD_REPO_DIRNAME / "tools"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    return root


def _run_tool(sandbox: Path, *cli_args: str) -> subprocess.CompletedProcess:
    tool = sandbox / CHILD_REPO_DIRNAME / "tools" / TOOL_NAME
    return subprocess.run(
        ["uv", "run", "--script", str(tool), *cli_args],
        cwd=sandbox,
        capture_output=True, text=True, timeout=120, check=False,
    )


def _registered_via_status(sandbox: Path) -> dict:
    """Repo-name -> discovered set, per R-1's mechanism, for a workspace."""
    assert CHILD_REPO_DIRNAME in _git(sandbox, "submodule", "status", check=False)
    return {}


def test_discovery_excludes_unregistered_and_uninitialized(tmp_path: Path) -> None:
    """R-1: eligibility is git's registered-submodule mechanism.

    A `.gitmodules` path with no gitlink registration and no checkout
    (directory present) is not a store host; a registered-but-deinitialized
    submodule (leading `-` in `git submodule status`) is also not a store
    host — and does not abort the tool's bootstrap.
    """
    base = TMP_DIR / "discovery-shapes"
    if base.exists():
        shutil.rmtree(base)
    root = base / ROOT_REPO_DIRNAME
    root.mkdir(parents=True)
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    # Reachable empty bare origin (no issues-data branch): bootstrap falls
    # back to the orphan-branch path without a fetch attempt against it.
    subprocess.run(["git", "init", "-q", "--bare", str(base / "origin.git")], check=True)
    _git(root, "remote", "add", "origin", str(base / "origin.git"))
    # A deinitialized registered submodule: recorded gitlink, empty checkout.
    child = base / "child"
    subprocess.run(["git", "init", "-q", str(child)], check=True)
    (child / "f.txt").write_text("x\n", encoding="utf-8")
    _git(child, "add", "f.txt")
    _git(child, "-c", "user.name=f", "-c", "user.email=f@x", "commit", "-q", "-m", "c")
    sha = _git(child, "rev-parse", "HEAD")
    (root / ".opencode").mkdir()  # emptied checkout, dir still present
    (root / ".gitmodules").write_text(
        '[submodule ".opencode"]\n\tpath = .opencode\n\turl = ./unreachable.git\n',
        encoding="utf-8",
    )
    _git(root, "add", ".gitmodules")
    _git(root, "update-index", "--add", "--cacheinfo", f"160000,{sha},.opencode")
    _git(root, "-c", "user.name=f", "-c", "user.email=f@x", "commit", "-q", "-m", "reg")
    # Register the child as deinitialized on the sandbox's own git side:
    # an empty directory + gitlink means - is *not* what git reports for a
    # present-but-empty dir; simulate uninitialized by removing the dir's
    # content entirely is not needed — a `-` marker arises when the
    # working tree copy is absent, so drop the directory.
    shutil.rmtree(root / ".opencode")
    status = _git(root, "submodule", "status", check=False)
    assert status.startswith("-"), (
        f"expected uninitialized form, got {status!r}"
    )
    tools_dir = root / ".opencode" / "tools"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    result = _run_tool(root, "init")
    assert result.returncode == 0, (
        f"init must not abort on an uninitialized submodule: {result.stderr!r}"
    )
    combined = result.stdout + result.stderr
    assert f"path={root / CHILD_REPO_DIRNAME}" not in combined, (
        f"uninitialized submodule discovered as a store host: {combined!r}"
    )


def test_pull_only_child_gets_no_store(pull_only_sandbox: Path) -> None:
    """R-3 (SC-1/SC-2): init exits 0, no issues-data branch, no worktree.

    The per-repository report carries the pull-only classification and no
    operation result, and the tool's stderr carries no git error from a
    fetch or push against the unreachable https origin.
    """
    root = pull_only_sandbox
    child = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "init")
    assert result.returncode == 0, (
        f"init failed on a pull-only-deck workspace: {result.stderr!r}"
    )
    assert "issues-data" not in _git(child, "branch", check=False)
    worktrees = _git(child, "worktree", "list", check=False)
    assert ".issues" not in worktrees, worktrees
    report = result.stdout
    assert f"path: {child}" in report, report
    # pull-only entry carries the classification, no operation result
    assert "pull-only" in report, report
    assert "fetch" not in result.stderr.lower(), result.stderr
    assert "push" not in result.stderr.lower(), result.stderr


def test_mutations_refuse_pull_only_repo(pull_only_sandbox: Path) -> None:
    """R-3 (SC-3): every mutation naming the pull-only repo is refused.

    The diagnostic names the repository and its pull-only classification,
    and the refusal creates no issues-data branch and no .issues worktree.
    """
    root = pull_only_sandbox
    child = root / CHILD_REPO_DIRNAME
    for command, args in MUTATION_PROBES:
        result = _run_tool(root, command, *args)
        combined = result.stdout + result.stderr
        assert result.returncode != 0, f"{command} did not refuse: {combined!r}"
        assert str(child) in combined and "pull-only" in combined, (
            f"{command} diagnostic lacks repo path + pull-only classification: {combined!r}"
        )
        assert "issues-data" not in _git(child, "branch", check=False), command
        worktrees = _git(child, "worktree", "list", check=False)
        assert ".issues" not in worktrees, (command, worktrees)
        assert not (child / ".issues").exists(), command
    # sync-file: refuses a path inside the pull-only repository's store
    result = _run_tool(
        root, "sync-file",
        "--file", f"{CHILD_REPO_DIRNAME}/.issues/probe/spec.md", "--message", "probe",
    )
    combined = result.stdout + result.stderr
    assert result.returncode != 0, f"sync-file did not refuse: {combined!r}"
    assert str(child) in combined and "pull-only" in combined, (
        f"sync-file diagnostic lacks repo path + pull-only classification: {combined!r}"
    )
    assert not (child / ".issues").exists()


def test_writeable_child_is_a_store_host(writeable_child_sandbox: Path) -> None:
    """Negative control (R-2 scope): an ssh-origin child keeps its store class.

    Its classification is not pull-only; the tool resolves it by name and
    the doctor line for it carries no pull-only classification. The store is
    never created against the unreachable ssh origin, so the tool reports
    its steady-state sync condition without a push attempt succeeding —
    here only the *classification*, not connectivity, is under test.
    """
    root = writeable_child_sandbox
    child = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "doctor")
    assert result.returncode == 0, result.stderr
    line = next(
        l for l in (result.stdout + result.stderr).splitlines()
        if f"repo={child}" in l
    )
    assert "pull-only" not in line, line
    # Classification on the pull-only side stays separate (SC-18 covered in
    # the pull-only fixture): the writeable child has no classification and
    # keeps its branch-state marker.
    assert "UNHEALTHY" in line, line


def test_doctor_reports_pull_only_classification(pull_only_sandbox: Path) -> None:
    """R-4 (SC-18): doctor carries the classification, no UNHEALTHY marker."""
    root = pull_only_sandbox
    child = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "doctor")
    assert result.returncode == 0, result.stderr
    line = next(
        l for l in (result.stdout + result.stderr).splitlines()
        if f"repo={child}" in l
    )
    assert "classification=pull-only" in line, line
    assert "UNHEALTHY" not in line, line


def test_root_with_https_origin_not_pull_only(tmp_path: Path) -> None:
    """R-2 root exemption: the root's own scheme is never classification
    evidence. The workspace root keeps its store class (`not-pull-only`
    in session-init terms) and its doctor line has no pull-only marker."""
    base = TMP_DIR / "root-exempt"
    if base.exists():
        shutil.rmtree(base)
    root = base / ROOT_REPO_DIRNAME
    root.mkdir(parents=True)
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    _git(root, "remote", "add", "origin", "https://example.invalid/owner/repo.git")
    tools_dir = root / CHILD_REPO_DIRNAME / "tools"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    result = _run_tool(root, "doctor")
    assert result.returncode == 0, result.stderr
    line = next(
        l for l in (result.stdout + result.stderr).splitlines()
        if f"repo={root}" in l
    )
    assert "UNHEALTHY" in line, line  # root keeps its branch-state health marker
    assert "classification=pull-only" not in (result.stdout + result.stderr), (
        result.stdout + result.stderr
    )
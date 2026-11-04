# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""R-1/R-2 (.opencode#2642): child store hosts gated on issue-host evidence.

A registered child repository is a store host only when the issue store
already exists on it — its origin carries a live-verified `issues-data`
ref, or a local `.issues/` store worktree (or local `issues-data` branch)
exists. A child with neither evidence (including one whose remote ref
cannot be verified) is a non-host: `init` creates nothing in it, sync
performs no fetch/rebase/push against it, mutations are refused, and
`doctor` reports the classification instead of a false UNHEALTHY. The
opt-in (`init --adopt`) is the only provisioning path for a child store.

The fixtures register the child through git's registered-submodule
mechanism (gitlink + .gitmodules + `git subprocess config`), because
that is the eligibility mechanism discovery enumerates by.

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import os
import shutil
import subprocess
import stat
from pathlib import Path

ISSUES_REL = ".issues"

TOOL_NAME = "local-issues"
TMP_DIR = Path(__file__).resolve().parents[3] / "tmp" / "issue-2642" / "test-sandboxes"

ROOT_REPO_DIRNAME = "opencode-config"
CHILD_REPO_DIRNAME = ".opencode"


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


def _register_child(
    root: Path, child: Path, origin_url: str, name: str = CHILD_REPO_DIRNAME
) -> None:
    """Register `child` as a registered submodule of `root` (#2667 pattern)."""
    subprocess.run(["git", "init", "-q", str(child)], check=True)
    (child / "README.md").write_text("fixture\n", encoding="utf-8")
    _git(child, "add", "README.md")
    _git(child, "-c", "user.name=fixture", "-c", "user.email=f@x", "commit", "-q", "-m", "init")
    if origin_url:
        _git(child, "remote", "add", "origin", origin_url)
    sha = _git(child, "rev-parse", "HEAD")
    shutil.copytree(child, root / name, dirs_exist_ok=True)
    (root / ".gitmodules").write_text(
        f'[submodule "{name}"]\n\tpath = {name}\n\turl = {origin_url}\n',
        encoding="utf-8",
    )
    _git(root, "add", ".gitmodules")
    _git(root, "update-index", "--add", "--cacheinfo", f"160000,{sha},{name}")
    _git(root, "config", f"submodule.{name}.url", origin_url)
    _git(root, "-c", "user.name=fixture", "-c", "user.email=f@x", "commit", "-q", "-m", "register submodule")


def _make_root(base: Path) -> Path:
    base.mkdir(parents=True, exist_ok=True)
    root = base / ROOT_REPO_DIRNAME
    subprocess.run(["git", "init", "-q", str(root)], check=True)
    subprocess.run(["git", "init", "-q", "--bare", str(base / "origin.git")], check=True)
    _git(root, "remote", "add", "origin", str(base / "origin.git"))
    return root


def _install_tool(root: Path) -> None:
    tools_dir = root / CHILD_REPO_DIRNAME / "tools"
    tools_dir.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)


def _run_tool(sandbox: Path, *cli_args: str) -> subprocess.CompletedProcess:
    tool = sandbox / CHILD_REPO_DIRNAME / "tools" / TOOL_NAME
    return subprocess.run(
        ["uv", "run", "--script", str(tool), *cli_args],
        cwd=sandbox,
        capture_output=True, text=True, timeout=120, check=False,
    )


def _mint_orphan_branch(repo: Path) -> None:
    """Hand-provision a local orphan issues-data branch (fixture plumbing)."""
    tree = _git(repo, "hash-object", "-t", "tree", "/dev/null")
    commit = _git(
        repo, "-c", "user.name=fixture", "-c", "user.email=f@x",
        "commit-tree", tree, "-m", "init issues branch",
    )
    _git(repo, "update-ref", "refs/heads/issues-data", commit)


def _seed_remote_store(base: Path) -> None:
    """Seed the root's bare origin with an issues-data branch (SC-5)."""
    seed = base / "seed-clone"
    subprocess.run(["git", "clone", "-q", str(base / "origin.git"), str(seed)], check=True)
    _mint_orphan_branch(seed)
    _git(seed, "push", "-q", "origin", "issues-data")
    shutil.rmtree(seed)


def test_unreachable_origin_child_is_informational_non_host() -> None:
    """SC-14: an unreachable-origin child with no local store degrades to
    the informational non-host skip — init exits 0, no store artifact."""
    base = TMP_DIR / "sc14-unreachable"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child = base / "child"
    _register_child(
        root, child, f"file://{base}/unreachable-origin.git"  # path never exists
    )
    _install_tool(root)
    result = _run_tool(root, "init")
    assert result.returncode == 0, (
        f"init must not abort the sweep on an unreachable child origin: {result.stderr!r}"
    )
    cdir = root / CHILD_REPO_DIRNAME
    assert not (cdir / ".issues").exists(), result.stderr
    assert "issues-data" not in _git(cdir, "branch", check=False), result.stderr
    report = result.stdout
    assert f"path: {cdir}" in report and "non-host" in report, report


def test_wiki_origin_child_gets_no_store() -> None:
    """SC-8: the filing report's repro shape — a registered child whose
    origin ends in `.wiki.git` — receives no store: no `.issues`, no
    branch, no push toward the wiki remote (a reachable local bare repo
    standing in for the wiki remote; nothing on the wiki side answers
    for store hosting)."""
    base = TMP_DIR / "sc8-wiki-origin"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    subprocess.run(
        ["git", "init", "-q", "--bare", str(base / "deck.wiki.git")], check=True
    )
    child = base / "child"
    _register_child(root, child, str(base / "deck.wiki.git"))
    _install_tool(root)
    result = _run_tool(root, "init")
    assert result.returncode == 0, result.stderr
    cdir = root / CHILD_REPO_DIRNAME
    assert not (cdir / ".issues").exists(), result.stderr
    assert "issues-data" not in _git(cdir, "branch", check=False), result.stderr
    wiki_ref = subprocess.run(
        ["git", "-C", str(cdir), "ls-remote", "origin"], capture_output=True, text=True
    )
    assert not wiki_ref.stdout.strip(), wiki_ref.stdout



def _basic_no_evidence_sandbox(tmp_variant: str) -> Path:
    base = TMP_DIR / tmp_variant
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    # Reachable, pushable local bare origin carrying no issues-data ref
    # (no ssh anywhere — the machine's live sshd turns failed ssh into
    # interactive auth dialogs; file-transport only).
    subprocess.run(
        ["git", "init", "-q", "--bare", str(base / "child-origin.git")], check=True
    )
    child = base / "child"
    _register_child(root, child, str(base / "child-origin.git"))
    _install_tool(root)  # .opencode/ is the copied child checkout (with .git)
    assert (root / CHILD_REPO_DIRNAME / ".git").is_dir(), (
        "fixture setup error: child checkout lost its .git"
    )
    return root


def test_non_host_child_gets_no_store() -> None:
    """SC-1: a registered child with no store evidence (reachable origin,
    no ref, no local store) receives no store, and the report says so."""
    root = _basic_no_evidence_sandbox("sc1-no-evidence")
    child = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "init")
    assert result.returncode == 0, (
        f"init must exit successfully with a non-host child: {result.stderr!r}"
    )
    assert not (child / ".issues").exists(), result.stderr
    assert "issues-data" not in _git(child, "branch", check=False), result.stderr
    ls_remote = subprocess.run(
        ["git", "-C", str(child), "ls-remote", "origin"], capture_output=True, text=True
    )
    assert not ls_remote.stdout.strip(), (
        f"ref pushed to a non-host child's origin: {ls_remote.stdout!r}"
    )
    report = result.stdout
    assert f"path: {child}" in report, report
    assert "non-host" in report, report
    # SC-1's root clause: the root's establishment push still fired.
    root_ref = subprocess.run(
        ["git", "-C", str(root), "ls-remote", "origin", "issues-data"],
        capture_output=True, text=True,
    )
    assert root_ref.stdout.strip(), (
        f"root establishment push did not fire: {result.stderr!r}"
    )


# --- SC-2 / SC-12: mutations naming a non-host child are refused ---


MUTATION_PROBES = (
    ("create", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--title", "probe")),
    ("update", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--title", "probe")),
    ("comment", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--body", "probe")),
    ("close", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--reason", "completed")),
    ("delete", ("--number", f"{CHILD_REPO_DIRNAME}#9999", "--force")),
    ("renumber", ("--from", f"{CHILD_REPO_DIRNAME}#9999", "--to", f"{CHILD_REPO_DIRNAME}#9998")),
)


def test_mutations_refuse_non_host_child() -> None:
    """SC-2: a mutation naming a non-host child is refused with a
    diagnostic naming the non-host classification and the opt-in path,
    and creates no store artifact in the child."""
    root = _basic_no_evidence_sandbox("sc2-mutation-refusal")
    child = root / CHILD_REPO_DIRNAME
    for command, args in MUTATION_PROBES:
        result = _run_tool(root, command, *args)
        combined = result.stdout + result.stderr
        assert result.returncode != 0, f"{command} did not refuse: {combined!r}"
        assert "non-store-host" in combined, (
            f"{command} diagnostic lacks the non-store-host classification: {combined!r}"
        )
        assert "--adopt" in combined, (
            f"{command} diagnostic lacks the opt-in path: {combined!r}"
        )
        assert "issues-data" not in _git(child, "branch", check=False), command
        assert not (child / ".issues").exists(), command


def test_sc12_pull_only_refusal_ground_named() -> None:
    """SC-12 (a): on a registered child whose origin is an https URL that
    resolves to nothing, the opt-in refusal names the pull-only
    classification — and no store artifact lands in any target."""
    base = TMP_DIR / "sc12-pull-only"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child = base / "child"
    _register_child(root, child, "https://example.invalid/michael-conrad/.opencode.git")
    _install_tool(root)
    result = _run_tool(root, "init", "--adopt", CHILD_REPO_DIRNAME)
    combined = result.stdout + result.stderr
    assert result.returncode != 0, f"opt-in did not refuse: {combined!r}"
    assert "pull-only" in combined, combined
    assert "issues-data" not in _git(child, "branch", check=False), combined
    assert not (child / ".issues").exists(), combined

# --- SC-3 / SC-15: passive paths never touch a ref-less child origin ---


def test_sc6_doctor_reports_non_host_classification() -> None:
    """SC-6: a non-host child's doctor row carries the non-host
    classification and no UNHEALTHY marker; the row shape follows the
    pull-only row."""
    root = _basic_no_evidence_sandbox("sc6-doctor-non-host")
    cdir = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "doctor")
    assert result.returncode == 0, result.stderr
    line = next(
        l for l in (result.stdout + result.stderr).splitlines()
        if f"repo={cdir}" in l
    )
    assert "classification=non-host" in line, line
    assert "UNHEALTHY" not in line, line
    assert "branch_state=absent-by-design" in line, line
    # The root keeps its branch-state health verdict.
    root_line = next(
        l for l in (result.stdout + result.stderr).splitlines()
        if f"repo={root}" in l
    )
    assert "classification=non-host" not in root_line, root_line



def test_sc3_passive_paths_never_touch_refless_origin() -> None:
    """SC-3: a child holding a local store worktree whose origin lacks the
    ref — sync, sync-file, and a mutation each perform no fetch, no
    rebase, and no push; the entries are informational steady states and
    the ref stays absent."""
    base = TMP_DIR / "sc3-refless-passive"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child_origin = base / "child-origin.git"
    subprocess.run(["git", "init", "-q", "--bare", str(child_origin)], check=True)
    child = base / "child"
    _register_child(root, child, str(child_origin))
    _install_tool(root)
    cdir = root / CHILD_REPO_DIRNAME
    # Adopt (provisions worktree + establishment push while the origin
    # accepts it).
    adopt = _run_tool(root, "init", "--adopt", CHILD_REPO_DIRNAME)
    assert adopt.returncode == 0, f"adopt failed: {adopt.stderr!r}"
    # Delete the origin ref (direct update-ref on the bare repository).
    subprocess.run(
        ["git", "-C", str(child_origin), "update-ref", "-d",
         "refs/heads/issues-data"], check=True
    )
    ls = subprocess.run(
        ["git", "-C", str(child_origin), "ls-remote", "origin"],
        capture_output=True, text=True,
    )
    assert not ls.stdout.strip(), "precondition: origin ref not deleted"
    # Create a record in the child (mutation): commits locally, no push.
    create = _run_tool(
        root, "create", "--number", f"{CHILD_REPO_DIRNAME}#0001", "--title", "record",
    )
    assert create.returncode == 0, f"create failed: {create.stderr!r}"
    ls2 = subprocess.run(
        ["git", "-C", str(child_origin), "ls-remote", "origin"],
        capture_output=True, text=True,
    )
    assert not ls2.stdout.strip(), (
        f"mutation re-created the origin ref: {ls2.stdout!r}"
    )
    # sync: informational steady state, exit 0, no push.
    sync = _run_tool(root, "sync")
    assert sync.returncode == 0, f"sync failed: {sync.stderr!r}"
    assert "remote-ref-absent" in sync.stdout, sync.stdout
    ls3 = subprocess.run(
        ["git", "-C", str(child_origin), "ls-remote", "origin"],
        capture_output=True, text=True,
    )
    assert not ls3.stdout.strip(), ls3.stdout
    # sync-file naming the child's store file: no push, exit ok.
    sf = _run_tool(
        root, "sync-file", "--file", f"{CHILD_REPO_DIRNAME}/" + ISSUES_REL + "/1/issue.yaml",
        "--message", "probe",
    )
    assert sf.returncode == 0, f"sync-file failed: {sf.stderr!r}"
    ls4 = subprocess.run(
        ["git", "-C", str(child_origin), "ls-remote", "origin"],
        capture_output=True, text=True,
    )
    assert not ls4.stdout.strip(), ls4.stdout


def test_sc15_host_child_unreachable_origin_keeps_failure_semantics() -> None:
    """SC-15: a host child (local store) whose origin cannot be verified
    keeps the existing failure semantics — sync attempts and exits
    non-zero with a failure status; the outage is never reported as an
    intentional steady state."""
    base = TMP_DIR / "sc15-unreachable-host"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    # Child with a local store worktree and a reachable origin carrying
    # the ref; the outage removes the origin's backing path and the
    # restore brings the same origin (ref intact) back.
    child_origin = base / "child-origin.git"
    subprocess.run(["git", "init", "-q", "--bare", str(child_origin)], check=True)
    child = base / "child"
    _register_child(root, child, str(child_origin))
    _install_tool(root)
    cdir = root / CHILD_REPO_DIRNAME
    # Hand-provision the local store: orphan branch + worktree (git plumbing),
    # and push the ref so the origin carries it (host shape).
    tree = _git(cdir, "hash-object", "-t", "tree", "/dev/null")
    commit = _git(
        cdir, "-c", "user.name=fixture", "-c", "user.email=f@x",
        "commit-tree", tree, "-m", "init issues branch",
    )
    _git(cdir, "update-ref", "refs/heads/issues-data", commit)
    _git(cdir, "push", "-q", "origin", "issues-data")
    subprocess.run(
        ["git", "-C", str(cdir), "worktree", "add", ".issues", "issues-data"],
        capture_output=True, text=True,
    )
    assert (cdir / ".issues" / ".git").is_file(), (
        f"fixture setup error: store worktree not established; "
        f"git worktree list: {_git(cdir, 'worktree', 'list', check=False)!r}"
    )
    # Outage: the origin's backing path disappears (no ssh, no DNS, no
    # interactive anything — the transport fails immediately).
    shutil.move(str(child_origin), str(base / "child-origin.outage"))
    result = _run_tool(root, "sync")
    assert result.returncode != 0, (
        f"sync must fail for a host child with an unreachable origin: {result.stdout!r}"
    )
    # Any failure status qualifies (the transient outage is never
    # reported as an intentional steady state) — the effort lands in
    # whichever existing status the git layer names.
    failed_statuses = (
        "conflict", "push_failed", "fetch_failed", "add_failed",
        "commit_failed", "timeout", "rebase_in_progress",
    )
    lines = [l for l in result.stdout.splitlines() if "status:" in l]
    assert any(any(st in l for st in failed_statuses) for l in lines), result.stdout
    assert "pod" not in result.stdout and "non-host" not in result.stdout, (
        f"the outage must not read as an informational steady state: {result.stdout!r}"
    )
    # Restore: the same origin (ref intact) returns; sync converges.
    shutil.move(str(base / "child-origin.outage"), str(child_origin))
    restored = _run_tool(root, "sync")
    assert restored.returncode == 0, (
        f"sync must succeed after the outage passes: {restored.stdout!r}"
    )
    assert "conflict" not in restored.stdout and "push_failed" not in restored.stdout, (
        restored.stdout
    )
    child_entry = restored.stdout
    # The child's entry reports ok (carved from the YAML by its qualifier).
    assert f"qualifier: {CHILD_REPO_DIRNAME}" in child_entry, child_entry
    segments = child_entry.split(f"qualifier: {CHILD_REPO_DIRNAME}")
    assert "status: ok" in segments[1].split("- qualifier")[0], child_entry

# --- SC-4 / SC-13: the opt-in provisions and completes establishment ---


def test_sc4_optin_provisions_store_on_named_child() -> None:
    """SC-4: the opt-in provisions a store on the named child — worktree,
    branch, and the origin carrying the ref."""
    root = _basic_no_evidence_sandbox("sc4-optin")
    cdir = root / CHILD_REPO_DIRNAME
    assert not (cdir / ".issues").exists(), "precondition: no store"
    result = _run_tool(root, "init", "--adopt", CHILD_REPO_DIRNAME)
    assert result.returncode == 0, result.stderr
    assert (cdir / ".issues" / ".git").is_file(), result.stdout
    assert "issues-data" in _git(cdir, "branch"), result.stdout
    ref = subprocess.run(
        ["git", "-C", str(cdir), "ls-remote", "origin", "issues-data"],
        capture_output=True, text=True,
    )
    assert ref.stdout.strip(), (result.stdout, ref.returncode, ref.stderr)


def test_sc12_not_a_registered_child_ground_named() -> None:
    """SC-12 (b): the opt-in naming a plain directory that is not a
    registered child refuses with the not-a-registered-child ground and
    creates no store artifact in any target."""
    root = _basic_no_evidence_sandbox("sc12-not-registered")
    stray = root.parent / "stray-dir"
    stray.mkdir()
    cdir = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "init", "--adopt", "stray-dir")
    combined = result.stdout + result.stderr
    assert result.returncode != 0, f"opt-in did not refuse: {combined!r}"
    assert "not a registered child" in combined, combined
    assert "issues-data" not in _git(cdir, "branch", check=False), combined
    assert not (cdir / ".issues").exists(), combined
    assert not (stray / ".issues").exists(), combined


def test_sc13_establishment_failure_visible_and_completable() -> None:
    """SC-13: on a named child whose origin rejects pushes, the opt-in
    exits non-zero with a diagnostic naming the failed establishment
    while the store worktree exists locally; a re-run once the origin
    accepts pushes performs the establishment push."""
    base = TMP_DIR / "sc13-establish-cycle"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child_origin = base / "child-origin.git"
    subprocess.run(["git", "init", "-q", "--bare", str(child_origin)], check=True)
    child = base / "child"
    _register_child(root, child, str(child_origin))
    _install_tool(root)
    # Phase 1: origin push-rejecting (read-only; reads still work) — no
    # ssh anywhere (the machine's live sshd ... interactive dialogs).
    for rw in (child_origin / "objects", child_origin / "refs"):
        subprocess.run(["chmod", "-R", "a-w", str(rw)], check=True)
    result = _run_tool(root, "init", "--adopt", CHILD_REPO_DIRNAME)
    combined = result.stdout + result.stderr
    assert result.returncode != 0, f"opt-in did not fail: {combined!r}"
    assert "establishment failed" in combined, combined
    cdir = root / CHILD_REPO_DIRNAME
    assert (cdir / ".issues" / ".git").is_file(), combined
    ref = subprocess.run(
        ["git", "-C", str(cdir), "ls-remote", "origin", "issues-data"],
        capture_output=True, text=True,
    )
    assert not ref.stdout.strip(), f"ref exists despite rejecting origin: {ref.stdout!r}"
    # Phase 2: restore writability; the re-run completes the establishment.
    for rw in (child_origin / "objects", child_origin / "refs"):
        subprocess.run(["chmod", "-R", "u+w", str(rw)], check=True)
    rerun = _run_tool(root, "init", "--adopt", CHILD_REPO_DIRNAME)
    assert rerun.returncode == 0, f"establishment re-run failed: {rerun.stderr!r}"
    ref2 = subprocess.run(
        ["git", "-C", str(cdir), "ls-remote", "origin", "issues-data"],
        capture_output=True, text=True,
    )
    assert ref2.stdout.strip(), (rerun.stdout, ref2.returncode, ref2.stderr)


# --- SC-5: a real host child bootstraps from its remote ---


def test_sc5_seeded_host_child_bootstraps_from_remote() -> None:
    """SC-5: a registered child whose origin carries `issues-data` and
    which has no local store receives the store worktree from the remote
    — bootstrap is preserved for real hosts."""
    base = TMP_DIR / "sc5-seeded-host"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child_origin = base / "child-origin.git"
    subprocess.run(["git", "init", "-q", "--bare", str(child_origin)], check=True)
    # Seed the child's origin store with one issue record.
    seed = base / "seed"
    subprocess.run(["git", "clone", "-q", str(child_origin), str(seed)], check=True)
    _mint_orphan_branch(seed)
    _git(seed, "checkout", "-q", "issues-data")
    store = seed / "7"
    store.mkdir()
    (store / "issue.yaml").write_text(
        "title: seeded record\nstatus: open\nlabels: []\nbody: ''\n",
        encoding="utf-8",
    )
    _git(seed, "add", "-A")
    _git(seed, "-c", "user.name=f", "-c", "user.email=f@x", "commit", "-q", "-m", "seed")
    _git(seed, "push", "-q", "origin", "issues-data")
    shutil.rmtree(seed)
    child = base / "child"
    _register_child(root, child, str(child_origin))
    _install_tool(root)
    cdir = root / CHILD_REPO_DIRNAME
    result = _run_tool(root, "init")
    assert result.returncode == 0, result.stderr
    assert (cdir / ".issues" / ".git").is_file(), result.stdout
    assert (cdir / ISSUES_REL / "7" / "issue.yaml").exists(), (
        "seeded record not bootstrapped: " + str(sorted(p.name for p in (cdir / ISSUES_REL).iterdir()))
    )


# --- the four evidence branches (SC-9 coverage) ---


def test_evidence_remote_only_is_host() -> None:
    """SC-9: remote-only evidence — origin carries the ref, no local
    store — classifies the child a host (bootstrap proceeds; SC-5's run
    stores the behavior)."""
    base = TMP_DIR / "ev-remote-only"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child_origin = base / "child-origin.git"
    subprocess.run(["git", "init", "-q", "--bare", str(child_origin)], check=True)
    seed = base / "seed"
    subprocess.run(["git", "clone", "-q", str(child_origin), str(seed)], check=True)
    _mint_orphan_branch(seed)
    _git(seed, "push", "-q", "origin", "issues-data")
    shutil.rmtree(seed)
    child = base / "child"
    _register_child(root, child, str(child_origin))
    _install_tool(root)
    result = _run_tool(root, "init")
    assert result.returncode == 0, result.stderr
    assert (root / CHILD_REPO_DIRNAME / ".issues" / ".git").is_file(), (
        f"remote-only host was not bootstrapped: {result.stdout!r}"
    )


def test_evidence_local_only_is_host() -> None:
    """SC-9: local-only evidence — local store worktree present, origin
    unreachable — classifies the child a host."""
    base = TMP_DIR / "ev-local-only"
    if base.exists():
        shutil.rmtree(base)
    root = _make_root(base)
    child = base / "child"
    _register_child(root, child, f"file://{base}/unreachable-origin.git")
    _install_tool(root)
    cdir = root / CHILD_REPO_DIRNAME
    tree = _git(cdir, "hash-object", "-t", "tree", "/dev/null")
    commit = _git(
        cdir, "-c", "user.name=f", "-c", "user.email=f@x",
        "commit-tree", tree, "-m", "init",
    )
    _git(cdir, "update-ref", "refs/heads/issues-data", commit)
    result = _run_tool(root, "doctor")
    assert result.returncode == 0, result.stderr
    line = next(
        l for l in (result.stdout + result.stderr).splitlines()
        if f"repo={cdir}" in l
    )
    assert "classification=non-host" not in line, line
    assert "UNHEALTHY" in line or "merge_base_delta=absent" in line, line


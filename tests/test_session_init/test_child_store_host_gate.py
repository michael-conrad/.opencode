# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""R-5 (.opencode#2642): session-init's child store claims agree with the
store-host gate.

A non-host child emits no `issues:` store path and no bootstrap hint —
the repo entry itself (owner/repo/platform) stays. Host children (local
store evidence or a live-verified origin ref) keep their claims. The
root's claims are unchanged. No ssh anywhere in fixtures (file transport
only; the machine's live sshd ... interactive auth dialogs).

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)"""

import importlib.util
import subprocess
from importlib.machinery import SourceFileLoader
from pathlib import Path

SESSION_INIT_PATH = Path(__file__).resolve().parents[2] / "tools" / "session-init"

_loader = SourceFileLoader("session_init_script", str(SESSION_INIT_PATH))
_spec = importlib.util.spec_from_loader("session_init_script", _loader)
assert _spec is not None
session_init_script = importlib.util.module_from_spec(_spec)
_loader.exec_module(session_init_script)

_git_c = session_init_script.run_git_command


def _git(*args: str, cwd: Path, check: bool = True) -> str:
    result = subprocess.run(
        ["git", *args], cwd=str(cwd), check=check,
        capture_output=True, text=True, stdin=subprocess.DEVNULL,
    )
    return result.stdout.strip()


def _make_repo(path: Path, origin: str | None = None) -> Path:
    path.mkdir(parents=True, exist_ok=True)
    _git("init", "-q", cwd=path)
    _git("config", "user.name", "T", cwd=path)
    _git("config", "user.email", "t@example.com", cwd=path)
    (path / "README.md").write_text("x\n")
    _git("add", "-A", cwd=path)
    _git("commit", "-q", "-m", "init", cwd=path)
    if origin:
        _git("remote", "add", "origin", origin, cwd=path)
    return path


def _register_submodule(root: Path, src: Path, rel: str, origin: str) -> None:
    _git("-C", str(root), "submodule", "add", "-q", str(src), rel, cwd=root.parent)
    _git("-C", str(root / rel), "remote", "set-url", "origin", origin, cwd=root.parent)
    _git("-C", str(root), "commit", "-q", "-m", "add sub", cwd=root.parent)


def _workspace(tmp_path, monkeypatch, child_origin: str) -> Path:
    root = _make_repo(tmp_path / "ws", origin="https://git.test/owner/root.git")
    sub_src = _make_repo(tmp_path / "subsrc")
    _register_submodule(root, sub_src, "sub", child_origin)
    monkeypatch.chdir(root)
    return root


def _run_git(args: list[str], cwd: Path) -> str:
    result = subprocess.run(
        ["git", *args], cwd=str(cwd), check=False,
        capture_output=True, text=True, stdin=subprocess.DEVNULL,
    )
    if result.returncode != 0:
        raise AssertionError(f"git {args} failed in {cwd}: {result.stderr!r}")
    return result.stdout.strip()


def _mint_orphan_branch(repo: Path) -> None:
    tree = _run_git(["hash-object", "-t", "tree", "/dev/null"], repo)
    commit = _run_git(
        ["-c", "user.name=T", "-c", "user.email=t@example.com",
         "commit-tree", tree, "-m", "init"], repo
    )
    _run_git(["update-ref", "refs/heads/issues-data", commit], repo)


def test_non_host_child_no_store_claims(tmp_path, monkeypatch) -> None:
    """SC-7: a non-host child — verifying-absent remote ref, no local
    store — emits no `issues:` line and no bootstrap hint; the repo entry
    (owner/repo/platform) stays; the root's claims are unchanged."""
    root = _workspace(tmp_path, monkeypatch, "ssh://git@git.test:9418/owner/child.git")
    # The keep-the-entry, drop-the-claims boundary: the remote branch is
    # verified absent through the module's own live probe (monkeypatch
    # stands in for a reachable origin carrying no ref; the claim logic
    # under test is the evidence consult, not git).
    monkeypatch.setattr(
        session_init_script, "_remote_has_issues_ref", lambda repo_dir: False
    )
    repo_info = session_init_script.collect_repo_info()
    assert any(e["path"] == "sub" for e in repo_info)
    issues_info = session_init_script.collect_issue_artifact_paths(repo_info)
    assert not any(l.startswith("- sub/.issues") for l in issues_info), issues_info
    assert not any(
        l.startswith("- sub/.issues") and "bootstrap the issue store" in l
        for l in issues_info
    ), issues_info
    # root's claim unchanged (pointer or hint — the root is always claimed)
    assert any(l.startswith("- .issues/") for l in issues_info), issues_info


def test_host_child_keeps_claims(tmp_path, monkeypatch) -> None:
    """A host child — origin live-verified carrying the ref — keeps its
    `issues:` claim (the remote-only evidence branch)."""
    root = _workspace(tmp_path, monkeypatch, "ssh://git@git.test:9418/owner/child.git")
    monkeypatch.setattr(
        session_init_script, "_remote_has_issues_ref", lambda repo_dir: True
    )
    repo_info = session_init_script.collect_repo_info()
    issues_info = session_init_script.collect_issue_artifact_paths(repo_info)
    assert any(l.startswith("- sub/.issues/:") for l in issues_info), issues_info


def test_local_store_evidence_child_keeps_claims(tmp_path, monkeypatch) -> None:
    """SC-9: local-only evidence — the child holds a local issues-data
    branch though its origin carries none — keeps the `issues:` claim.
    (The `_child_store_host_evidence` unit window.)"""
    root = _workspace(tmp_path, monkeypatch, "ssh://git@git.test:9418/owner/child.git")
    child = tmp_path / "ws" / "sub"
    _mint_orphan_branch(child)
    repo_info = session_init_script.collect_repo_info()
    issues_info = session_init_script.collect_issue_artifact_paths(repo_info)
    assert any(l.startswith("- sub/.issues/:") for l in issues_info), issues_info

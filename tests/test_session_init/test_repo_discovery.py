"""Tests for session-init strict submodule discovery, wiki exclusion, and
self-healing cleanup (issue 2544).
"""

import importlib.util
import os
import subprocess
from importlib.machinery import SourceFileLoader
from pathlib import Path

import pytest

SESSION_INIT_PATH = Path(__file__).resolve().parents[2] / "tools" / "session-init"

_loader = SourceFileLoader("session_init_script", str(SESSION_INIT_PATH))
_spec = importlib.util.spec_from_loader("session_init_script", _loader)
assert _spec is not None
session_init_script = importlib.util.module_from_spec(_spec)
_loader.exec_module(session_init_script)

collect_repo_info = session_init_script.collect_repo_info
install_hooks = session_init_script.install_hooks
self_heal_hooks = session_init_script.self_heal_hooks
collect_hook_inventory = session_init_script.collect_hook_inventory


def _git(*args: str, cwd: Path) -> None:
    subprocess.run(
        ["git", *args],
        cwd=str(cwd),
        check=True,
        capture_output=True,
        stdin=subprocess.DEVNULL,
    )


def _make_repo(path: Path, origin: str | None = None) -> Path:
    path.mkdir(parents=True)
    _git("init", "-q", cwd=path)
    _git("config", "user.name", "Test", cwd=path)
    _git("config", "user.email", "test@example.com", cwd=path)
    (path / "README.md").write_text("x\n")
    _git("add", "-A", cwd=path)
    _git("commit", "-q", "-m", "init", cwd=path)
    if origin:
        _git("remote", "add", "origin", origin, cwd=path)
    return path


@pytest.fixture()
def workspace(tmp_path, monkeypatch):
    """Fixture workspace: root repo + registered submodule (parseable origin)
    + ignored sub-repo (unregistered, parseable origin)."""
    tmp = tmp_path
    root = _make_repo(tmp / "ws", origin="https://git.test/owner/root.git")
    sub_src = _make_repo(tmp / "subsrc")
    _git("-C", str(root), "submodule", "add", "-q", str(sub_src), "sub", cwd=tmp)
    _git("-C", str(root / "sub"), "remote", "set-url", "origin",
         "https://git.test/owner/sub.git", cwd=tmp)
    _git("-C", str(root), "commit", "-q", "-m", "add sub", cwd=tmp)
    _make_repo(root / "rogue", origin="https://git.test/owner/rogue.git")
    monkeypatch.chdir(root)
    return root


HOOK_CONTENT = "#!/bin/sh\n.trunk-guard\n"


@pytest.fixture()
def deck(workspace):
    """A deck-shaped git repo at <ws>/.opencode with hook source files and
    one committed historical version of hooks/pre-commit."""
    deck_root = workspace / ".opencode"
    _make_repo(deck_root, origin="https://git.test/owner/deck.git")
    hooks = deck_root / "hooks"
    hooks.mkdir()
    (hooks / "pre-commit").write_text(HOOK_CONTENT)
    (hooks / "pre-push").write_text(HOOK_CONTENT)
    _git("add", "-A", cwd=deck_root)
    _git("commit", "-q", "-m", "hooks", cwd=deck_root)
    return deck_root


class TestStrictDiscovery:
    """Spec item 1: registered-submodule mechanism only."""

    def test_ignored_subrepo_absent_from_inventory(self, workspace):
        entries = {e["path"] for e in collect_repo_info()}
        assert "rogue" not in entries, entries

    def test_registered_submodule_covered(self, workspace):
        entries = {e["path"]: e for e in collect_repo_info()}
        assert "." in entries
        assert entries["sub"]["repo"] == "sub"
        assert entries["sub"]["url"] == "https://git.test/owner/sub.git"

    def test_nested_registered_submodule_covered(self, workspace, tmp_path):
        """Stated extension: registered-tree submodules deeper than the old
        two-level scan reach are covered."""
        nested_src = _make_repo(tmp_path / "nestedsrc")
        sub = workspace / "sub"
        _git("-C", str(sub), "submodule", "add", "-q", str(nested_src), "nested",
             cwd=tmp_path)
        _git("-C", str(sub / "nested"), "remote", "set-url", "origin",
             "https://git.test/owner/nested.git", cwd=tmp_path)
        _git("-C", str(sub), "add", "-A", cwd=tmp_path)
        _git("-C", str(sub), "commit", "-q", "-m", "add nested", cwd=tmp_path)
        entries = {e["path"]: e for e in collect_repo_info()}
        assert entries["sub/nested"]["repo"] == "nested"

    def test_unregistered_container_submodule_not_covered(self, workspace,
                                                          tmp_path):
        """A submodule registered inside a NON-registered container is not in
        the coverage set (workspace orchestrates only its registered tree)."""
        inner_src = _make_repo(tmp_path / "innersrc")
        _git("-C", str(workspace / "rogue"), "submodule", "add", "-q",
             str(inner_src), "inner", cwd=tmp_path)
        _git("-C", str(workspace / "rogue" / "inner"), "remote", "set-url",
             "origin", "https://git.test/owner/inner.git", cwd=tmp_path)
        entries = {e["path"] for e in collect_repo_info()}
        assert "rogue/inner" not in entries
        assert "rogue" not in entries


class TestWikiExclusion:
    """Spec item 2: origin-based wiki exclusion at every level."""

    def test_registered_wiki_submodule_excluded(self, workspace, tmp_path):
        wiki_src = _make_repo(tmp_path / "wikisrc")
        _git("-C", str(workspace), "submodule", "add", "-q", str(wiki_src),
             "proj.wiki", cwd=tmp_path)
        _git("-C", str(workspace / "proj.wiki"), "remote", "set-url", "origin",
             "https://git.test/owner/proj.wiki.git", cwd=tmp_path)
        _git("-C", str(workspace), "add", "-A", cwd=tmp_path)
        _git("-C", str(workspace), "commit", "-q", "-m", "add wiki", cwd=tmp_path)
        entries = {e["path"] for e in collect_repo_info()}
        assert "proj.wiki" not in entries

    def test_wiki_repo_never_hooked(self, workspace, tmp_path, deck):
        wiki_src = _make_repo(tmp_path / "wikisrc")
        _git("-C", str(workspace), "submodule", "add", "-q", str(wiki_src),
             "proj.wiki", cwd=tmp_path)
        _git("-C", str(workspace / "proj.wiki"), "remote", "set-url", "origin",
             "https://git.test/owner/proj.wiki.git", cwd=tmp_path)
        _git("-C", str(workspace), "commit", "-q", "-m", "add wiki", cwd=tmp_path)
        install_hooks()
        target = workspace / "proj.wiki" / ".git" / "hooks"
        assert not (target / "pre-commit").exists()

    def test_ignored_wiki_subrepo_not_hooked(self, workspace, deck):
        wiki = _make_repo(workspace / "other.wiki",
                          origin="https://git.test/owner/other.wiki.git")
        install_hooks()
        assert not (wiki / ".git" / "hooks" / "pre-commit").exists()


class TestRegressionInvariant:
    """Spec item 5: root + non-wiki registered submodule behave as today."""

    def test_hooks_installed_in_root_and_submodule(self, workspace, deck):
        install_hooks()
        assert (workspace / ".git" / "hooks" / "pre-commit").exists()
        assert (workspace / ".git" / "hooks" / "pre-push").exists()
        # submodule hooks resolve into .git/modules/<name>/hooks
        found = any(
            (p / "pre-commit").exists()
            for p in (workspace / ".git" / "modules").rglob("hooks")
        )
        assert found, "registered submodule hooks not installed"

    def test_inventory_lines_for_covered_repos(self, workspace, deck):
        lines = collect_hook_inventory()
        assert any(l.startswith("- .: ") for l in lines)
        assert any(l.startswith("- sub: ") for l in lines)
        assert not any("rogue" in l for l in lines)

    def test_issues_store_worktree_not_in_inventory(self, workspace, deck):
        """A linked worktree shaped like .issues/ is not a covered entry."""
        _git("worktree", "add", "-b", "issues-data", str(workspace / ".issues"),
             "HEAD", cwd=workspace)
        entries = {e["path"] for e in collect_repo_info()}
        assert ".issues" not in entries


class TestSelfHeal:
    """Spec items 3-4: bounded cleanup enumeration + self-healing removal."""

    def _install_legacy_pollution(self, repo: Path, name: str = "pre-commit",
                                  content: str = HOOK_CONTENT) -> None:
        hooks = repo / ".git" / "hooks"
        hooks.mkdir(parents=True, exist_ok=True)
        (hooks / name).write_text(content)

    def test_matching_pollution_removed_and_reported(self, workspace, deck,
                                                     capsys):
        self._install_legacy_pollution(workspace / "rogue")
        removals = self_heal_hooks()
        hook = workspace / "rogue" / ".git" / "hooks" / "pre-commit"
        assert not hook.exists()
        assert removals and "rogue" in removals[0] and "pre-commit" in removals[0]

    def test_foreign_name_untouched(self, workspace, deck):
        self._install_legacy_pollution(workspace / "rogue", name="commit-msg")
        self_heal_hooks()
        assert (workspace / "rogue" / ".git" / "hooks" / "commit-msg").exists()

    def test_foreign_content_untouched(self, workspace, deck):
        self._install_legacy_pollution(workspace / "rogue",
                                       content="#!/bin/sh\nforeign\n")
        self_heal_hooks()
        hook = workspace / "rogue" / ".git" / "hooks" / "pre-commit"
        assert hook.exists() and hook.read_text() == "#!/bin/sh\nforeign\n"

    def test_coverage_hooks_dirs_untouched(self, workspace, deck):
        """Cleanup never acts on a hooks dir resolving to a coverage-set repo."""
        install_hooks()
        root_hook = workspace / ".git" / "hooks" / "pre-commit"
        before = root_hook.read_text()
        self_heal_hooks()
        assert root_hook.read_text() == before

    def test_sample_files_untouched(self, workspace, deck):
        samples = workspace / "rogue" / ".git" / "hooks"
        samples.mkdir(parents=True, exist_ok=True)
        (samples / "pre-commit.sample").write_text(HOOK_CONTENT)
        self_heal_hooks()
        assert (samples / "pre-commit.sample").exists()

    def test_wiki_pollution_self_healed(self, workspace, tmp_path, deck):
        """The hermes-admin scenario: hooks copied into a wiki checkout are
        removed; the wiki never appears in inventory."""
        wiki_src = _make_repo(tmp_path / "wikisrc")
        _git("-C", str(workspace), "submodule", "add", "-q", str(wiki_src),
             "proj.wiki", cwd=tmp_path)
        _git("-C", str(workspace / "proj.wiki"), "remote", "set-url", "origin",
             "https://git.test/owner/proj.wiki.git", cwd=tmp_path)
        _git("-C", str(workspace), "commit", "-q", "-m", "add wiki", cwd=tmp_path)
        wiki_hooks = session_init_script._resolve_hooks_target(
            str(workspace / "proj.wiki")
        )
        assert wiki_hooks
        os.makedirs(wiki_hooks, exist_ok=True)
        (Path(wiki_hooks) / "pre-commit").write_text(HOOK_CONTENT)
        removals = self_heal_hooks()
        assert not (Path(wiki_hooks) / "pre-commit").exists()
        assert any("proj.wiki" in r for r in removals)
        assert not any("proj.wiki" in l for l in collect_hook_inventory())
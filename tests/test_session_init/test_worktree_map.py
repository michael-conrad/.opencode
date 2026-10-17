"""Tests for session-init deviation-triggered worktree map (issue 1255).

Fixtures are real scratch git repositories built under tmp_path; session-init
runs in-process via main() with cwd monkeypatched and stdout captured.
"""

import importlib.util
import re
import shutil
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

ISSUES_BRANCH = "issues-data"


def git(*args: str, cwd: Path) -> subprocess.CompletedProcess[str]:
    result = subprocess.run(
        ["git", "-C", str(cwd), *args],
        capture_output=True,
        text=True,
        check=True,
    )
    return result


def make_repo(path: Path, origin: str | None = None) -> Path:
    """Create a git repo with one commit; optional origin remote."""
    path.mkdir(parents=True)
    git("init", "-q", "-b", "main", cwd=path)
    git("config", "user.name", "Fixture User", cwd=path)
    git("config", "user.email", "fixture@example.com", cwd=path)
    (path / "README.md").write_text("fixture\n")
    git("add", "-A", cwd=path)
    git("commit", "-q", "-m", "init", cwd=path)
    if origin:
        git("remote", "add", "origin", origin, cwd=path)
    return path


def worktree_add(
    repo: Path,
    wt_path: Path,
    branch: str | None = None,
    detach: bool = False,
) -> Path:
    args = ["worktree", "add", "-q"]
    if detach:
        args.append("--detach")
    elif branch:
        args += ["-b", branch]
    args.append(str(wt_path))
    if branch and not detach:
        pass
    git(*args, cwd=repo)
    if not detach:
        git("config", "user.name", "Fixture User", cwd=wt_path)
        git("config", "user.email", "fixture@example.com", cwd=wt_path)
    return wt_path


def add_issues_store(repo: Path, branch: str = ISSUES_BRANCH) -> Path:
    """Standard `.issues` store worktree (or an anomalous branch for T4)."""
    return worktree_add(repo, repo / ".issues", branch=branch)


def run_session_init(monkeypatch: pytest.MonkeyPatch, cwd: Path) -> str:
    monkeypatch.chdir(cwd)
    import contextlib
    import io

    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        session_init_script.main()
    return buf.getvalue()


def map_section(output: str) -> list[str]:
    """The `## Worktree Map` section: title line through the line before the
    next `## ` marker. Raises when the section is absent."""
    lines = output.splitlines()
    start = lines.index("## Worktree Map")
    end = len(lines)
    for i in range(start + 1, len(lines)):
        if lines[i].startswith("## "):
            end = i
            break
    return lines[start:end]


def expect_no_map(output: str) -> None:
    assert "## Worktree Map" not in output, f"unexpected map in output:\n{output}"


def remove_worktree(repo: Path, wt_path: Path, branch: str | None = None) -> None:
    git("worktree", "remove", "--force", str(wt_path), cwd=repo)
    git("worktree", "prune", cwd=repo)
    if branch:
        git("branch", "-D", branch, cwd=repo)
    registrations = git("worktree", "list", "--porcelain", cwd=repo).stdout
    assert str(wt_path) not in registrations, "residual worktree registration"


# ---------------------------------------------------------------------------
# Standard-shape fixtures
# ---------------------------------------------------------------------------

@pytest.fixture
def standard_repo(tmp_path: Path) -> Path:
    """A repo whose worktree set is standard: main worktree only (no store)."""
    return make_repo(tmp_path / "proj", origin="https://example.com/o/proj.git")


@pytest.fixture
def standard_repo_with_store(tmp_path: Path) -> Path:
    """Standard topology: main worktree + `.issues` store on `issues-data`."""
    repo = make_repo(tmp_path / "proj", origin="https://example.com/o/proj.git")
    add_issues_store(repo)
    return repo


# ---------------------------------------------------------------------------
# Guards (regression — run pre-change and after every subsequent item)
# ---------------------------------------------------------------------------


class TestPreExistingSurfacePreserved:
    """SC-2 regression guard: pre-existing sections and Worktree: line."""

    def test_ordered_markers_from_main_worktree(
        self, standard_repo: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        output = run_session_init(monkeypatch, standard_repo)
        markers = [
            "## CLI Auth Status",
            "## Hook Inventory (report-only)",
            "## Local Issue Folders",
            "## Repo Information",
            "## Agent Tools",
        ]
        positions = [output.find(m) for m in markers]
        assert all(p >= 0 for p in positions), f"missing marker: {markers}"
        assert positions == sorted(positions), f"out of order: {positions}"

    def test_worktree_line_inside_linked_worktree(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/wt", branch="feature/guard")
        try:
            output = run_session_init(monkeypatch, wt)
        finally:
            remove_worktree(standard_repo, wt, branch="feature/guard")
        assert "Worktree: " in output


class TestEmbeddedRepoExcluded:
    """SC-9 regression guard: embedded non-submodule repo never surfaces."""

    def test_embedded_repo_invisible(
        self, standard_repo: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        embedded = standard_repo / "vendor-thing"
        embedded.mkdir()
        git("init", "-q", cwd=embedded)
        gitignore = standard_repo / ".gitignore"
        gitignore.write_text("vendor-thing/\n")
        git("add", "-A", cwd=standard_repo)
        git("commit", "-q", "-m", "ignore vendor", cwd=standard_repo)

        output = run_session_init(monkeypatch, standard_repo)
        expect_no_map(output)
        assert "vendor-thing" not in output


# ---------------------------------------------------------------------------
# Core enumeration (SC-7 + SC-8 assertions live in this cycle)
# ---------------------------------------------------------------------------


class TestMapCompleteness:
    """SC-7: exactly complete map, groups in Repo Information order."""

    @pytest.fixture
    def submodule_workspace(self, tmp_path: Path) -> tuple[Path, Path, Path, Path]:
        child = make_repo(tmp_path / "child", origin="https://example.com/o/sub.git")
        parent = make_repo(tmp_path / "parent", origin="https://example.com/o/parent.git")
        git("submodule", "add", "-q", str(child), "sub", cwd=parent)
        git("remote", "set-url", "origin", "https://example.com/o/sub.git", cwd=parent / "sub")
        git("commit", "-q", "-m", "add submodule", cwd=parent)
        sub = parent / "sub"
        sub_store = add_issues_store(sub)
        feat_wt = worktree_add(parent, parent / ".worktrees/feat", branch="feature/x")
        return parent, sub, feat_wt, sub_store

    def test_groups_and_rows_exactly_match_topology(
        self,
        submodule_workspace: tuple[Path, Path, Path, Path],
        tmp_path: Path,
        monkeypatch: pytest.MonkeyPatch,
    ) -> None:
        parent, sub, feat_wt, sub_store = submodule_workspace
        try:
            output = run_session_init(monkeypatch, parent)
        finally:
            remove_worktree(parent, feat_wt, branch="feature/x")
            remove_worktree(sub, sub_store, branch=ISSUES_BRANCH)

        section = map_section(output)
        groups: dict[str, list[str]] = {}
        current_group = None
        for line in section[2:]:  # skip title + blank
            if not line:
                continue
            if line.startswith("submodule ") or (line.endswith(":") and not line.startswith(" ")):
                current_group = line
                groups[current_group] = []
            else:
                assert current_group is not None, f"row before any group: {line}"
                groups[current_group].append(line.strip())

        parent_header = "o/parent:"
        sub_header = "submodule sub:"
        assert list(groups.keys()) == [parent_header, sub_header], groups.keys()
        assert groups[parent_header] == [".worktrees/feat [feature/x]"], groups
        assert groups[sub_header] == ["sub/.issues [issues-data]"], groups

    def test_no_modules_gitdir_and_no_main_row(
        self,
        submodule_workspace: tuple[str, Path, Path, Path],
        tmp_path: Path,
        monkeypatch: pytest.MonkeyPatch,
    ) -> None:
        parent, sub, feat_wt, sub_store = submodule_workspace
        try:
            output = run_session_init(monkeypatch, parent)
        finally:
            remove_worktree(parent, feat_wt, branch="feature/x")
            remove_worktree(sub, sub_store, branch=ISSUES_BRANCH)

        section = "\n".join(map_section(output))
        assert ".git/modules" not in section
        assert str(parent) not in section  # no absolute paths
        # the submodule's main worktree row (the module gitdir) never renders
        rows = [line for line in section.splitlines() if line.startswith("  ")]
        assert all("sub/" in row or ".issues" in row or ".worktrees" in row for row in rows)


# ---------------------------------------------------------------------------
# Row features
# ---------------------------------------------------------------------------


class TestNonStandardWorktreeRow:
    """SC-3: non-standard linked worktree with its actual branch."""

    def test_branch_displayed(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/wt", branch="feature/abc")
        actual = git("rev-parse", "--abbrev-ref", "HEAD", cwd=wt).stdout.strip()
        try:
            output = run_session_init(monkeypatch, standard_repo)
        finally:
            remove_worktree(standard_repo, wt, branch="feature/abc")

        assert actual == "feature/abc"
        section = "\n".join(map_section(output))
        rows = [line for line in section.splitlines() if line.startswith("  ")]
        assert rows == ["  .worktrees/wt [feature/abc]"], rows


class TestPrunableRow:
    """SC-4: removed-directory worktree marked prunable."""

    def test_prunable_then_prune(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/stale", branch="feature/stale")
        shutil.rmtree(wt)
        output = run_session_init(monkeypatch, standard_repo)
        section = "\n".join(map_section(output))
        assert "prunable" in section

        git("worktree", "prune", cwd=standard_repo)
        git("branch", "-D", "feature/stale", cwd=standard_repo)
        registrations = git("worktree", "list", "--porcelain", cwd=standard_repo).stdout
        assert str(standard_repo / ".worktrees/stale") not in registrations


class TestCurrentFlag:
    """SC-5: running inside a non-standard linked worktree marks its row current."""

    def test_current_marks_running_worktree(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/wt", branch="feature/cur")
        try:
            output = run_session_init(monkeypatch, wt)
        finally:
            remove_worktree(standard_repo, wt, branch="feature/cur")

        rows = [line for line in map_section(output) if line.startswith("  ")]
        current_rows = [r for r in rows if "current" in r]
        assert len(current_rows) == 1, rows
        assert current_rows[0] == "  .worktrees/wt [feature/cur] current", rows


class TestDetachedRow:
    """SC-10: detached-HEAD worktree renders [detached] with no SHA."""

    def test_detached_no_sha(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/dw", detach=True)
        try:
            output = run_session_init(monkeypatch, standard_repo)
        finally:
            git("worktree", "remove", "--force", str(wt), cwd=standard_repo)
            git("worktree", "prune", cwd=standard_repo)

        rows = [line for line in map_section(output) if line.startswith("  ")]
        assert rows == ["  .worktrees/dw [detached]"], rows
        assert not re.search(r"[0-9a-f]{7,40}", " ".join(rows))


class TestStoreBranchAnomaly:
    """SC-11: `.issues` store on a non-issues-data branch triggers the map."""

    def test_store_alt_branch(
        self, standard_repo: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        store = add_issues_store(standard_repo, branch="alt-store")
        try:
            output = run_session_init(monkeypatch, standard_repo)
        finally:
            remove_worktree(standard_repo, store, branch="alt-store")

        rows = [line for line in map_section(output) if line.startswith("  ")]
        assert rows == ["  .issues [alt-store]"], rows


class TestWhitespacePathQuoting:
    """SC-6 edge: whitespace-containing relpath is single-quoted."""

    def test_quoted_relpath(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/my wt", branch="feature/ws")
        try:
            output = run_session_init(monkeypatch, standard_repo)
        finally:
            remove_worktree(standard_repo, wt, branch="feature/ws")

        rows = [line for line in map_section(output) if line.startswith("  ")]
        assert rows == ["  '.worktrees/my wt' [feature/ws]"], rows


# ---------------------------------------------------------------------------
# Emission gating, grammar, placement
# ---------------------------------------------------------------------------


class TestNoMapInStandardShape:
    """SC-1: standard topology emits no map."""

    def test_no_map_with_store(
        self, standard_repo_with_store: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        output = run_session_init(monkeypatch, standard_repo_with_store)
        expect_no_map(output)

    def test_no_map_without_store(
        self, standard_repo: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        output = run_session_init(monkeypatch, standard_repo)
        expect_no_map(output)

    def test_no_map_running_inside_store(
        self, standard_repo_with_store: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        output = run_session_init(
            monkeypatch, standard_repo_with_store / ".issues"
        )
        expect_no_map(output)


class TestMapGrammar:
    """SC-6: every map-section line conforms to the section grammar."""

    def test_zero_nonconforming_lines(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/wt", branch="feature/grammar")
        try:
            output = run_session_init(monkeypatch, standard_repo)
        finally:
            remove_worktree(standard_repo, wt, branch="feature/grammar")

        section = map_section(output)
        group_header = re.compile(r"^(?:[^/\s]+/[^:\s]+|submodule [^:\s]+):$")
        row = re.compile(
            r"^  (?:'[^']*'|\S+) \[(?:[^\s\]]+|detached)\]"
            r"(?: current)?(?: prunable)?$"
        )
        seen_title = section[0] == "## Worktree Map"
        assert seen_title
        for line in section[1:]:
            if not line:
                continue
            assert group_header.match(line) or row.match(line), f"non-conforming: {line!r}"
        # no SHA, no absolute path, no prose
        body = "\n".join(section)
        assert not re.search(r"[0-9a-f]{7,40}", body)
        for line in section[1:]:
            if line and not line.startswith("  "):
                assert line.endswith(":"), f"prose-like line: {line!r}"


class TestMapPlacement:
    """SC-12: map appears between Local Issue Folders and Repo Information."""

    def test_marker_order(
        self, standard_repo: Path, tmp_path: Path, monkeypatch: pytest.MonkeyPatch
    ) -> None:
        wt = worktree_add(standard_repo, standard_repo / ".worktrees/wt", branch="feature/pos")
        try:
            output = run_session_init(monkeypatch, standard_repo)
        finally:
            remove_worktree(standard_repo, wt, branch="feature/pos")

        li = output.index("## Local Issue Folders")
        wm = output.index("## Worktree Map")
        ri = output.index("## Repo Information")
        assert li < wm < ri


# SPDX-FileCopyrightText: 2026 Michael Conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored — .opencode#1255 test surface
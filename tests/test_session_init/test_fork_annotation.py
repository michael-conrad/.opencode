"""Behavioral tests: fork_of annotation in session-init output (SC-1, SC-2, SC-4).

Executes tools/session-init in fixture clones with prepared stamps.
"""

import json
import os
import shutil
import subprocess
import sys

import pytest

REPO_ROOT = os.path.abspath(
    os.path.join(os.path.dirname(__file__), "..", "..")
)
SESSION_INIT = os.path.join(REPO_ROOT, "tools", "session-init")


def _init_clone(tmp_path, origin_url):
    repo = tmp_path / "clone"
    subprocess.run(["git", "init", "-q", str(repo)], check=True)
    subprocess.run(
        ["git", "-C", str(repo), "remote", "add", "origin", origin_url],
        check=True,
    )
    subprocess.run(
        ["git", "-C", str(repo), "config", "user.email", "t@example.com"],
        check=True,
    )
    subprocess.run(
        ["git", "-C", str(repo), "config", "user.name", "t"], check=True
    )
    return repo


def _stamp(repo, stamps):
    d = os.path.join(str(repo), ".git", "opencode")
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "fork.json"), "w") as f:
        json.dump(stamps, f)


def _run(repo, extra_path=None):
    env = dict(os.environ)
    if extra_path is not None:
        env["PATH"] = extra_path
    return subprocess.run(
        [sys.executable, SESSION_INIT],
        cwd=str(repo), capture_output=True, text=True, timeout=60,
        env=env,
    )


def _parse_entries(out):
    """Parse ## Repo Information entries into {url: [lines]}."""
    entries = {}
    in_section = False
    current = None
    for line in out.splitlines():
        if line.startswith("## "):
            in_section = line == "## Repo Information"
            continue
        if in_section and line.startswith("- "):
            current = []
        elif in_section and line.startswith("  ") and current is not None:
            current.append(line.strip())
            if line.strip().startswith("url: "):
                entries[line.strip()[5:]] = current
    return entries


@pytest.fixture
def shim_bin(tmp_path):
    """A PATH dir exposing only git (no gh/gb) — simulates offline."""
    d = tmp_path / "shim"
    d.mkdir()
    git_path = shutil.which("git")
    os.symlink(git_path, d / "git")
    return str(d)


class TestForkAnnotation:
    def test_fork_stamp_renders_fork_of_line(self, tmp_path):
        repo = _init_clone(
            tmp_path, "https://github.com/fork-owner/forked-repo.git"
        )
        _stamp(repo, {
            "https://github.com/fork-owner/forked-repo.git": {
                "fork": True, "parent": "upstream/forked-repo",
                "probed_at": 9999999999.0, "result": "fork",
            }
        })
        proc = _run(repo)
        assert proc.returncode == 0
        entry = _parse_entries(proc.stdout)[
            "https://github.com/fork-owner/forked-repo.git"
        ]
        assert "fork_of: upstream/forked-repo" in entry
        assert sum(1 for ln in entry if ln.startswith("fork_of:")) == 1

    def test_no_stamp_no_annotation(self, tmp_path):
        repo = _init_clone(
            tmp_path, "https://github.com/some-owner/some-repo.git"
        )
        proc = _run(repo)
        assert proc.returncode == 0
        assert "fork_of:" not in proc.stdout

    def test_only_stamped_entry_gains_annotation(self, tmp_path):
        repo = _init_clone(
            tmp_path, "https://github.com/fork-owner/forked-repo.git"
        )
        _stamp(repo, {
            "https://github.com/fork-owner/forked-repo.git": {
                "fork": True, "parent": "upstream/forked-repo",
                "probed_at": 9999999999.0, "result": "fork",
            },
        })
        proc = _run(repo)
        lines = [
            ln for ln in proc.stdout.splitlines()
            if "fork_of:" in ln
        ]
        assert lines == ["  fork_of: upstream/forked-repo"]


class TestOffline:
    def test_offline_run_completes_with_identical_structure(
        self, tmp_path, shim_bin
    ):
        repo = _init_clone(
            tmp_path, "https://github.com/off-owner/off-repo.git"
        )
        online = _run(repo)
        offline = _run(repo, extra_path=shim_bin)
        assert offline.returncode == 0
        assert offline.stderr == ""
        def section_lines(stdout):
            lines = stdout.splitlines()
            start = next(
                i for i, l in enumerate(lines)
                if l == "## Repo Information"
            )
            end = next(
                i for i, l in enumerate(lines)
                if l.startswith("project_root:")
            )
            return lines[start:end]

        assert section_lines(offline.stdout) == section_lines(online.stdout)
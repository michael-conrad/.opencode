"""Unit tests for session_init.fork_stamp — SC-1…SC-8 support."""

import json
import os
import subprocess
import time
from unittest.mock import MagicMock, patch

import pytest

from session_init import fork_stamp


@pytest.fixture
def git_dir(tmp_path):
    d = tmp_path / "gitdir"
    d.mkdir()
    return d


class TestStampPath:
    def test_stamp_path_shape(self, git_dir):
        path = fork_stamp.stamp_path(str(git_dir))
        assert path.endswith("opencode/fork.json")
        assert path.startswith(str(git_dir))

    def test_stamp_file_not_created_by_path_call(self, git_dir):
        fork_stamp.stamp_path(str(git_dir))
        assert not os.path.exists(os.path.join(str(git_dir), "opencode", "fork.json"))


class TestStampRoundTrip:
    def test_save_then_load(self, git_dir):
        entries = {
            "https://github.com/owner/repo.git": {
                "fork": True,
                "parent": "upstream/repo",
                "probed_at": "2026-10-06T00:00:00+00:00",
                "result": "fork",
            }
        }
        fork_stamp.save_stamps(str(git_dir), entries)
        loaded = fork_stamp.load_stamps(str(git_dir))
        assert loaded == entries

    def test_parent_absent_for_not_fork(self, git_dir):
        entries = {
            "https://github.com/owner/repo.git": {
                "fork": False,
                "parent": None,
                "probed_at": "2026-10-06T00:00:00+00:00",
                "result": "not_fork",
            }
        }
        fork_stamp.save_stamps(str(git_dir), entries)
        loaded = fork_stamp.load_stamps(str(git_dir))
        assert loaded == entries
        assert loaded["https://github.com/owner/repo.git"]["parent"] is None

    def test_load_missing_file(self, git_dir):
        assert fork_stamp.load_stamps(str(git_dir)) == {}

    def test_load_corrupt_file_treated_absent(self, git_dir):
        os.makedirs(os.path.join(str(git_dir), "opencode"))
        with open(os.path.join(str(git_dir), "opencode", "fork.json"), "w") as f:
            f.write("{not json")
        assert fork_stamp.load_stamps(str(git_dir)) == {}

    def test_load_non_dict_file_treated_absent(self, git_dir):
        os.makedirs(os.path.join(str(git_dir), "opencode"))
        with open(os.path.join(str(git_dir), "opencode", "fork.json"), "w") as f:
            json.dump(["a", "list"], f)
        assert fork_stamp.load_stamps(str(git_dir)) == {}

    def test_save_is_atomic_no_temp_leftovers(self, git_dir):
        entries = {"u": {"fork": False, "probed_at": "t", "result": "not_fork"}}
        fork_stamp.save_stamps(str(git_dir), entries)
        leftovers = [
            n
            for n in os.listdir(os.path.join(str(git_dir), "opencode"))
            if n != "fork.json"
        ]
        assert leftovers == [], f"temp files left behind: {leftovers}"


class TestFreshness:
    def _entry(self, probed_at_epoch):
        return {
            "fork": False,
            "parent": None,
            "probed_at": probed_at_epoch,
            "result": "not_fork",
        }

    def test_fresh_entry_is_fresh(self):
        now = time.time()
        assert fork_stamp.is_fresh(self._entry(now - 100)) is True

    def test_entry_older_than_ttl_is_stale(self):
        now = time.time()
        ttl = fork_stamp.TTL_SECONDS
        assert fork_stamp.is_fresh(self._entry(now - ttl - 60)) is False

    def test_entry_at_boundary_is_stale(self):
        now = time.time()
        assert fork_stamp.is_fresh(self._entry(now - fork_stamp.TTL_SECONDS)) is False

    def test_missing_or_malformed_timestamp_is_stale(self):
        assert fork_stamp.is_fresh({"fork": False, "result": "not_fork"}) is False
        assert fork_stamp.is_fresh({"probed_at": "garbage"}) is False


@pytest.fixture
def mock_subprocess_run():
    with patch("session_init.fork_stamp.subprocess.run") as mock:
        yield mock


class TestProbe:
    def _result(self, returncode=0, stdout="", stderr=""):
        r = MagicMock()
        r.returncode = returncode
        r.stdout = stdout
        r.stderr = stderr
        return r

    def test_gh_fork_with_parent(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(
            stdout=json.dumps(
                {"isFork": True,
                 "parent": {"name": "repo", "owner": {"login": "up"}}}
            )
        )
        entry = fork_stamp.probe_target("github.com", "own", "repo")
        assert entry is not None
        assert entry["fork"] is True
        assert entry["parent"] == "up/repo"
        assert entry["result"] == "fork"

    def test_gh_not_a_fork(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(
            stdout=json.dumps({"isFork": False, "parent": None})
        )
        entry = fork_stamp.probe_target("github.com", "own", "repo")
        assert entry is not None
        assert entry["fork"] is False
        assert entry["parent"] is None
        assert entry["result"] == "not_fork"

    def test_gh_command_failure_writes_nothing(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(returncode=1, stderr="boom")
        assert fork_stamp.probe_target("github.com", "own", "repo") is None

    def test_gh_malformed_json_writes_nothing(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(stdout="{bad")
        assert fork_stamp.probe_target("github.com", "own", "repo") is None

    def test_gh_missing_fields_writes_nothing(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(stdout=json.dumps({}))
        assert fork_stamp.probe_target("github.com", "own", "repo") is None

    def test_gb_fork_with_parent(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(
            stdout=json.dumps({"fork": True, "parent": {"full_name": "up/repo"}})
        )
        entry = fork_stamp.probe_target("gitbucket.example.com", "own", "repo")
        assert entry is not None
        assert entry["fork"] is True
        assert entry["parent"] == "up/repo"
        assert entry["result"] == "fork"

    def test_gb_fork_parent_absent_is_negative_result(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(
            stdout=json.dumps({"fork": True})
        )
        entry = fork_stamp.probe_target("gitbucket.example.com", "own", "repo")
        assert entry is not None
        assert entry["fork"] is True
        assert entry["parent"] is None
        assert entry["result"] == "parent_absent"

    def test_gb_command_failure_writes_nothing(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(returncode=1, stderr="boom")
        assert fork_stamp.probe_target("gitbucket.example.com", "own", "repo") is None

    def test_probe_timeout_raises_is_silent(self, mock_subprocess_run):
        mock_subprocess_run.side_effect = TimeoutError()
        assert fork_stamp.probe_target("github.com", "own", "repo") is None

    def test_unknown_platform_attempts_gb_best_effort(self, mock_subprocess_run):
        mock_subprocess_run.return_value = self._result(returncode=1)
        assert fork_stamp.probe_target("example.org", "own", "repo") is None
        cmd = mock_subprocess_run.call_args[0][0]
        assert cmd[0] == "gb"


class TestNoRawHttp:
    def test_no_http_client_imports(self):
        src = open(fork_stamp.__file__).read()
        for banned in ("import http", "import urllib", "import requests",
                       "import aiohttp", "urllib.request", "http.client"):
            assert banned not in src, f"hand-rolled HTTP found: {banned}"


@pytest.fixture
def mock_popen(tmp_path):
    with patch("session_init.fork_stamp.subprocess.Popen") as mock, \
         patch("session_init.fork_stamp.run_git_command_quiet",
               return_value=str(tmp_path / "gitdir")):
        (tmp_path / "gitdir").mkdir()
        yield mock


class TestSpawn:
    def _targets(self):
        return [
            {"url": "https://github.com/own/repo.git",
             "platform": "github.com", "owner": "own", "repo": "repo"},
            {"url": "https://gitbucket.example.com/own/other.git",
             "platform": "gitbucket.example.com", "owner": "own",
             "repo": "other"},
        ]

    def test_spawns_detached_with_devnull(self, mock_popen):
        fork_stamp.spawn_background_probe(self._targets())
        kwargs = mock_popen.call_args[1]
        assert kwargs.get("start_new_session") is True
        assert kwargs.get("stdin") == subprocess.DEVNULL
        assert kwargs.get("stdout") == subprocess.DEVNULL
        assert kwargs.get("stderr") == subprocess.DEVNULL

    def test_spawn_args_carry_probe_flag_and_targets(self, mock_popen):
        fork_stamp.spawn_background_probe(self._targets())
        args = mock_popen.call_args[0][0]
        assert args[0].endswith("python") or "python" in args[0]
        assert args[-2] == "--probe"
        payload = json.loads(args[-1])
        assert payload == self._targets()

    def test_deduplicates_targets_by_url(self, mock_popen):
        targets = self._targets() + [self._targets()[0]]
        fork_stamp.spawn_background_probe(targets)
        payload = json.loads(mock_popen.call_args[0][0][-1])
        assert len(payload) == 2

    def test_spawn_failure_is_silent(self, mock_popen):
        mock_popen.side_effect = OSError("no fork")
        fork_stamp.spawn_background_probe(self._targets())  # must not raise


class TestProbeAndStamp:
    def _git_dir(self, tmp_path):
        return str(tmp_path / "gitdir")

    def test_probes_missing_targets_and_saves(self, tmp_path, mock_subprocess_run):
        gd = self._git_dir(tmp_path)
        mock_subprocess_run.return_value = MagicMock(
            returncode=0,
            stdout=json.dumps({"isFork": False, "parent": None}),
        )
        targets = [{"url": "u1", "platform": "github.com",
                    "owner": "o", "repo": "r"}]
        fork_stamp.probe_and_stamp(gd, targets)
        stamps = fork_stamp.load_stamps(gd)
        assert stamps["u1"]["result"] == "not_fork"

    def test_fresh_targets_skipped_zero_probe_calls(self, tmp_path, mock_subprocess_run):
        gd = self._git_dir(tmp_path)
        fork_stamp.save_stamps(gd, {
            "u1": {"fork": False, "parent": None,
                   "probed_at": time.time(), "result": "not_fork"},
        })
        targets = [{"url": "u1", "platform": "github.com",
                    "owner": "o", "repo": "r"}]
        fork_stamp.probe_and_stamp(gd, targets)
        mock_subprocess_run.assert_not_called()

    def test_failed_probe_leaves_stamp_unchanged(self, tmp_path, mock_subprocess_run):
        gd = self._git_dir(tmp_path)
        existing = {"u1": {"fork": True, "parent": "up/r",
                           "probed_at": time.time(), "result": "fork"}}
        fork_stamp.save_stamps(gd, existing)
        mock_subprocess_run.return_value = MagicMock(returncode=1)
        targets = [{"url": "u2", "platform": "github.com",
                    "owner": "o", "repo": "r"}]
        fork_stamp.probe_and_stamp(gd, targets)
        assert fork_stamp.load_stamps(gd) == existing

    def test_stale_target_reprobed(self, tmp_path, mock_subprocess_run):
        gd = self._git_dir(tmp_path)
        fork_stamp.save_stamps(gd, {
            "u1": {"fork": False, "parent": None,
                   "probed_at": time.time() - fork_stamp.TTL_SECONDS - 60,
                   "result": "not_fork"},
        })
        mock_subprocess_run.return_value = MagicMock(
            returncode=0,
            stdout=json.dumps({"isFork": True,
                               "parent": {"name": "r",
                                          "owner": {"login": "up"}}}),
        )
        targets = [{"url": "u1", "platform": "github.com",
                    "owner": "o", "repo": "r"}]
        fork_stamp.probe_and_stamp(gd, targets)
        stamps = fork_stamp.load_stamps(gd)
        assert stamps["u1"]["result"] == "fork"
        assert stamps["u1"]["parent"] == "up/r"
        assert mock_subprocess_run.call_count == 1


class TestAnnotation:
    def test_fork_stamp_yields_annotation(self):
        parents = fork_stamp.fresh_fork_parents({
            "u1": {"fork": True, "parent": "up/repo",
                   "probed_at": time.time(), "result": "fork"},
        })
        assert parents == {"u1": "up/repo"}

    def test_not_fork_yields_nothing(self):
        parents = fork_stamp.fresh_fork_parents({
            "u1": {"fork": False, "parent": None,
                   "probed_at": time.time(), "result": "not_fork"},
        })
        assert parents == {}

    def test_parent_absent_negative_yields_nothing(self):
        parents = fork_stamp.fresh_fork_parents({
            "u1": {"fork": True, "parent": None,
                   "probed_at": time.time(), "result": "parent_absent"},
        })
        assert parents == {}

    def test_stale_fork_yields_nothing(self):
        parents = fork_stamp.fresh_fork_parents({
            "u1": {"fork": True, "parent": "up/repo",
                   "probed_at": time.time() - fork_stamp.TTL_SECONDS - 60,
                   "result": "fork"},
        })
        assert parents == {}
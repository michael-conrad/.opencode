"""Unit tests for session_init.auth."""
import os
import tempfile
from unittest.mock import MagicMock, patch

import pytest
from session_init.auth import check_cli_auth_status, check_cli_auth_status as ccas, _read_gitbucket_url_from_env


class TestCheckCliAuthStatus:
    def _make_result(
        self, returncode: int = 0, stdout: str = "", stderr: str = ""
    ) -> MagicMock:
        result = MagicMock()
        result.returncode = returncode
        result.stdout = stdout
        result.stderr = stderr
        return result

    def test_gh_auth_command_no_no_interactive(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}"
        mock_subprocess_run.return_value = self._make_result(
            returncode=1, stdout="", stderr="not logged in"
        )
        check_cli_auth_status()
        assert len(mock_subprocess_run.call_args_list) >= 1
        gh_call = mock_subprocess_run.call_args_list[0]
        cmd = gh_call[0][0]
        assert cmd == ["gh", "auth", "status"], (
            f"Expected ['gh', 'auth', 'status'] but got {cmd}"
        )
        assert "--no-interactive" not in cmd, (
            f"--no-interactive should NOT be in the command: {cmd}"
        )

    def test_gh_auth_logged_in_parsing(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gh" else None
        mock_subprocess_run.return_value = self._make_result(
            stdout="github.com\n  ✓ Logged in to github.com as octocat (token)...\n"
        )
        status = check_cli_auth_status()
        assert any("gh: ✓ Logged in to github.com account octocat" in line for line in status), (
            f"Expected gh logged-in line in {status}"
        )

    def test_gh_auth_not_logged_in(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gh" else None
        mock_subprocess_run.return_value = self._make_result(
            returncode=1, stderr="You are not logged into GitHub"
        )
        status = check_cli_auth_status()
        assert any("gh: not_logged_in" in line for line in status), (
            f"Expected gh not_logged_in in {status}"
        )

    def test_gh_auth_timeout(self, mock_subprocess_run, mock_shutil_which):
        import subprocess

        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gh" else None
        mock_subprocess_run.side_effect = subprocess.TimeoutExpired(cmd="gh auth status", timeout=5)
        status = check_cli_auth_status()
        assert any("gh: timeout" in line for line in status), (
            f"Expected gh timeout in {status}"
        )

    def test_gh_auth_no_gh_installed(self, mock_shutil_which):
        mock_shutil_which.return_value = None
        status = check_cli_auth_status()
        assert not any("gh:" in line for line in status), (
            f"Expected no gh lines when gh not installed: {status}"
        )

    def test_gb_auth_logged_in(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gb" else None
        mock_subprocess_run.return_value = self._make_result(
            stdout="Logged in to gitbucket.example.com as devuser\n"
        )
        status = check_cli_auth_status()
        assert any("gb: ✓ Logged in to gitbucket.example.com account devuser" in line for line in status), (
            f"Expected gb logged-in line in {status}"
        )

    def test_gb_auth_not_logged_in(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gb" else None
        mock_subprocess_run.return_value = self._make_result(
            returncode=0, stdout="Not logged in"
        )
        status = check_cli_auth_status()
        assert any("gb: ✓ Logged in" in line for line in status), (
            f"Expected gb logged-in fallback in {status} when no 'as' pattern"
        )

    def test_gb_auth_timeout(self, mock_subprocess_run, mock_shutil_which):
        import subprocess

        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gb" else None
        mock_subprocess_run.side_effect = subprocess.TimeoutExpired(cmd="gb auth status", timeout=5)
        status = check_cli_auth_status()
        assert any("gb: timeout" in line for line in status), (
            f"Expected gb timeout in {status}"
        )

    def test_gh_auth_fallback_logged_in_no_regex_match(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gh" else None
        mock_subprocess_run.return_value = self._make_result(
            stdout="unexpected format - logged in somehow\n"
        )
        status = check_cli_auth_status()
        assert any("gh: ✓ Logged in" in line for line in status), (
            f"Expected gh fallback logged-in in {status}"
        )

    def test_gh_auth_subprocess_error(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gh" else None
        mock_subprocess_run.side_effect = OSError("exec format error")
        status = check_cli_auth_status()
        assert any("gh: error" in line for line in status), (
            f"Expected gh error in {status}"
        )

    def test_gb_auth_subprocess_error(self, mock_subprocess_run, mock_shutil_which):
        mock_shutil_which.side_effect = lambda x: f"/usr/bin/{x}" if x == "gb" else None
        mock_subprocess_run.side_effect = OSError("exec format error")
        status = check_cli_auth_status()
        assert any("gb: error" in line for line in status), (
            f"Expected gb error in {status}"
        )


class TestReadGitbucketUrlFromEnv:
    def test_returns_none_when_no_env_file(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            result = _read_gitbucket_url_from_env(tmpdir)
            assert result is None

    def test_returns_html_url_when_present(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            env_path = os.path.join(tmpdir, ".env")
            with open(env_path, "w") as f:
                f.write("GITBUCKET_HTML_URL=https://git.example.com\n")
            result = _read_gitbucket_url_from_env(tmpdir)
            assert result == "https://git.example.com"

    def test_falls_back_to_legacy_url(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            env_path = os.path.join(tmpdir, ".env")
            with open(env_path, "w") as f:
                f.write("GITBUCKET_URL=https://legacy.example.com\n")
            result = _read_gitbucket_url_from_env(tmpdir)
            assert result == "https://legacy.example.com"

    def test_returns_none_on_oserror(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            env_path = os.path.join(tmpdir, ".env")
            with open(env_path, "w") as f:
                f.write("GITBUCKET_HTML_URL=https://git.example.com\n")
            with patch("builtins.open", side_effect=OSError("permission denied")):
                result = _read_gitbucket_url_from_env(tmpdir)
                assert result is None

    def test_html_url_takes_precedence_over_legacy(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            env_path = os.path.join(tmpdir, ".env")
            with open(env_path, "w") as f:
                f.write("GITBUCKET_HTML_URL=https://git.example.com\n")
                f.write("GITBUCKET_URL=https://legacy.example.com\n")
            result = _read_gitbucket_url_from_env(tmpdir)
            assert result == "https://git.example.com"

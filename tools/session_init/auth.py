"""CLI auth status checker for gh and gb."""
import os
import re
import shutil
import subprocess

NETWORK_TIMEOUT = 5


def _read_gitbucket_url_from_env(project_root: str) -> str | None:
    """Read GITBUCKET_HTML_URL (preferred) or GITBUCKET_URL (legacy) from .env file."""
    try:
        env_path = os.path.join(project_root, ".env")
        if os.path.exists(env_path):
            html_url = None
            legacy_url = None
            with open(env_path) as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("GITBUCKET_HTML_URL="):
                        html_url = line.split("=", 1)[1].strip()
                    elif line.startswith("GITBUCKET_URL="):
                        legacy_url = line.split("=", 1)[1].strip()
            return html_url or legacy_url
    except OSError:
        pass
    return None


def check_cli_auth_status() -> list[str]:
    """Check gh and gb CLI auth status. Returns list of status lines.

    For each CLI:
    - Check if binary exists via shutil.which()
    - If installed, run auth status with short timeout (5s)
    - Parse output for logged-in status — extract minimal one-liner
    - Redact any sensitive values (tokens, emails)
    - If not installed, skip silently — no output for that CLI

    Returns an empty list if no CLIs are installed.
    """
    status_lines: list[str] = []

    # Check gh
    gh_path = shutil.which("gh")
    if gh_path:
        try:
            result = subprocess.run(
                ["gh", "auth", "status"],
                capture_output=True,
                text=True,
                check=False,
                stdin=subprocess.DEVNULL,
                timeout=NETWORK_TIMEOUT,
            )
            if result.returncode == 0:
                line = (result.stdout or result.stderr or "").strip()
                match = re.search(
                    r"Logged in to (\S+) as (\S+)",
                    line,
                )
                if match:
                    host = match.group(1)
                    account = match.group(2)
                    status_lines.append(
                        f"gh: ✓ Logged in to {host} account {account}"
                    )
                else:
                    status_lines.append("gh: ✓ Logged in")
            else:
                status_lines.append("gh: not_logged_in")
        except subprocess.TimeoutExpired:
            status_lines.append("gh: timeout")
        except (subprocess.SubprocessError, OSError):
            status_lines.append("gh: error")

    # Check gb
    gb_path = shutil.which("gb")
    if gb_path:
        try:
            result = subprocess.run(
                ["gb", "auth", "status"],
                capture_output=True,
                text=True,
                check=False,
                stdin=subprocess.DEVNULL,
                timeout=NETWORK_TIMEOUT,
            )
            if result.returncode == 0:
                line = (result.stdout or result.stderr or "").strip()
                match = re.search(
                    r"Logged in to (\S+) as (\S+)",
                    line,
                )
                if match:
                    host = match.group(1)
                    account = match.group(2)
                    status_lines.append(
                        f"gb: ✓ Logged in to {host} account {account}"
                    )
                else:
                    status_lines.append("gb: ✓ Logged in")
            else:
                status_lines.append("gb: not_logged_in")
        except subprocess.TimeoutExpired:
            status_lines.append("gb: timeout")
        except (subprocess.SubprocessError, OSError):
            status_lines.append("gb: error")

    return status_lines

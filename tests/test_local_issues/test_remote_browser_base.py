# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
"""Behavioral matrix for `_remote_browser_base` / `url` (issue 2623).

Covers the scheme × host-mapping matrix from the #2623 spec:

- ssh:// and git+ssh:// origin forms parse (user, port, .git optional).
- A committed host-mapping config maps a hostname to a browser base,
  scheme-independently: any origin form carrying a mapped hostname
  resolves to the mapped base (SC-1, SC-6).
- Unmapped hostnames keep today's derived conversion (SC-2): scp-style
  and https origins unchanged; ssh:// origins fall back to same-host
  https.
- Missing origin / unparseable URL still exit 1 with the current error
  text (SC-4).
- Config optionality: absent config and config without an applicable
  entry both degrade to derived conversion (SC-7).
- A present-but-unparseable config file warns (stderr, path + error
  class) and proceeds with derived conversion (SC-8).

Runs the tool CLI inside an isolated sandbox repo whose origin is set
per case; the host-mapping config is written beside the sandbox tool
copy per case (the loader resolves the config relative to the tool's
own location).

Co-authored with AI: OpenCode (huggingface/zai-org/GLM-5.3-Flash)
"""

import shutil
import subprocess
from pathlib import Path

import pytest

TOOL_NAME = "local-issues"
CONFIG_NAME = "local-issues-host-maps.conf"

FAMILY_HOST = "tomcat-0002.newsrx.com"
FAMILY_BASE = "https://gitbucket.newsrx.com/gitbucket"
FAMILY_OWNER = "NewSRX-Tech-LLC"
FAMILY_REPO = "NewsRxUI"


def _find_project_root() -> Path:
    path = Path(__file__).resolve()
    while path.name != ".opencode":
        if path.parent == path:
            raise RuntimeError("Could not find .opencode/ directory")
        path = path.parent
    return path.parent


PROJECT_ROOT = _find_project_root()
REAL_TOOL = PROJECT_ROOT / ".opencode" / "tools" / TOOL_NAME
TMP_DIR = PROJECT_ROOT / "tmp" / "issue-2623" / "test-sandboxes"


def _git(*args: str, cwd: Path) -> None:
    result = subprocess.run(
        ["git", *args],
        cwd=cwd,
        capture_output=True,
        text=True,
        timeout=30,
        check=False,
    )
    assert result.returncode == 0, f"git {' '.join(args)} failed: {result.stderr!r}"


@pytest.fixture
def sandbox() -> Path:
    """Sandbox repo (name 'repo') with a tool copy; origin set per test."""
    base = TMP_DIR / "run-2623"
    if base.exists():
        shutil.rmtree(base)
    root = base / "workspace"
    repo = root / "repo"
    tools_dir = root / ".opencode" / "tools"
    tools_dir.mkdir(parents=True)
    repo.mkdir(parents=True)
    shutil.copy2(REAL_TOOL, tools_dir / TOOL_NAME)
    tool_copy = tools_dir / TOOL_NAME
    tool_copy.chmod(0o755)
    _git("init", "-q", cwd=repo)
    return root


def _set_origin(root: Path, url: str) -> None:
    _git("remote", "add", "origin", url, cwd=root / "repo")


def _write_config(root: Path, content: str | None) -> None:
    if content is None:
        return
    (root / ".opencode" / "tools" / CONFIG_NAME).write_text(content)


def _run_url(root: Path, number: str = "workspace#7", artifacts: bool = False):
    cmd = [
        "uv",
        "run",
        "--script",
        str(root / ".opencode" / "tools" / TOOL_NAME),
        "url",
        "--number",
        number,
    ]
    if artifacts:
        cmd.append("--artifacts")
    return subprocess.run(
        cmd,
        cwd=root / "repo",
        capture_output=True,
        text=True,
        timeout=60,
        check=False,
    )


FAMILY_CONFIG = f"{FAMILY_HOST} = {FAMILY_BASE}\n"

# --- SC-1: mapped family host, ssh:// origin (user, port, .git) ---


def test_sc1_mapped_ssh_full_form_issues_url(sandbox):
    _set_origin(
        sandbox,
        f"ssh://git@{FAMILY_HOST}:29418/{FAMILY_OWNER}/{FAMILY_REPO}.git",
    )
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert (
        result.stdout.strip()
        == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"
    )


def test_sc1_mapped_ssh_full_form_artifacts_url(sandbox):
    _set_origin(
        sandbox,
        f"ssh://git@{FAMILY_HOST}:29418/{FAMILY_OWNER}/{FAMILY_REPO}.git",
    )
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox, artifacts=True)
    assert result.returncode == 0, result.stderr
    assert (
        result.stdout.strip()
        == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/tree/issues-data/7/"
    )


# --- SC-6: mapping is scheme-independent over origin forms ---


def test_sc6_mapped_git_plus_ssh(sandbox):
    _set_origin(
        sandbox,
        f"git+ssh://git@{FAMILY_HOST}:29418/{FAMILY_OWNER}/{FAMILY_REPO}.git",
    )
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


def test_sc6_mapped_scp_form(sandbox):
    _set_origin(sandbox, f"git@{FAMILY_HOST}:{FAMILY_OWNER}/{FAMILY_REPO}.git")
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


def test_sc6_mapped_https(sandbox):
    _set_origin(sandbox, f"https://{FAMILY_HOST}/{FAMILY_OWNER}/{FAMILY_REPO}.git")
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


def test_sc6_mapped_ssh_portless_userless(sandbox):
    _set_origin(sandbox, f"ssh://{FAMILY_HOST}/{FAMILY_OWNER}/{FAMILY_REPO}")
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


# --- SC-9: optional grammar components ---


def test_sc9_ssh_userless_ported(sandbox):
    _set_origin(
        sandbox,
        f"ssh://{FAMILY_HOST}:29418/{FAMILY_OWNER}/{FAMILY_REPO}.git",
    )
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


def test_sc9_ssh_portless_with_user_dot_git_absent(sandbox):
    _set_origin(sandbox, f"ssh://git@{FAMILY_HOST}/{FAMILY_OWNER}/{FAMILY_REPO}")
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


def test_sc9_git_plus_ssh_userless_portless(sandbox):
    _set_origin(sandbox, f"git+ssh://{FAMILY_HOST}/{FAMILY_OWNER}/{FAMILY_REPO}.git")
    _write_config(sandbox, FAMILY_CONFIG)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == f"{FAMILY_BASE}/{FAMILY_OWNER}/{FAMILY_REPO}/issues/7"


# --- SC-2: unmapped hostnames keep today's derived conversion ---


def test_sc2_unmapped_ssh_same_host_https(sandbox):
    _set_origin(sandbox, "ssh://git@gitlab.example.com:2222/acme/widget.git")
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "https://gitlab.example.com/acme/widget/issues/7"


def test_sc2_unmapped_scp_unchanged(sandbox):
    _set_origin(sandbox, "git@github.com:acme/widget.git")
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "https://github.com/acme/widget/issues/7"


def test_sc3_unmapped_https_unchanged(sandbox):
    _set_origin(sandbox, "https://github.com/acme/widget.git")
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "https://github.com/acme/widget/issues/7"


def test_sc3_git_plus_ssh_unmapped_parses(sandbox):
    _set_origin(sandbox, "git+ssh://git@gitlab.example.com/acme/widget.git")
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "https://gitlab.example.com/acme/widget/issues/7"


# --- SC-4: preserved error paths ---


def test_sc4_missing_origin_exits_1(sandbox):
    result = _run_url(sandbox)
    assert result.returncode == 1
    assert (
        "error: no usable origin remote for repo 'workspace'" in result.stderr
    )


def test_sc4_unparseable_url_exits_1(sandbox):
    _set_origin(sandbox, "not-a-remote-url")
    result = _run_url(sandbox)
    assert result.returncode == 1
    assert (
        "error: no usable origin remote for repo 'workspace'" in result.stderr
    )


# --- SC-7: config optionality ---


def test_sc7_no_config_file_ssh_still_parses(sandbox):
    _set_origin(sandbox, "ssh://git@gitlab.example.com/acme/widget.git")
    # No config file written at all.
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "https://gitlab.example.com/acme/widget/issues/7"


def test_sc7_config_without_applicable_entry(sandbox):
    _set_origin(sandbox, "ssh://git@gitlab.example.com/acme/widget.git")
    _write_config(sandbox, f"{FAMILY_HOST} = {FAMILY_BASE}\n")
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    assert result.stdout.strip() == "https://gitlab.example.com/acme/widget/issues/7"


# --- SC-8: corrupt config degrades with a warning, never a crash ---


def test_sc8_corrupt_config_warns_and_derives(sandbox):
    _set_origin(sandbox, "ssh://git@gitlab.example.com/acme/widget.git")
    corrupt_path = (
        "this line has no equals sign\n"
        "= missing key\n"
        "valid_without_value =\n"
    )
    _write_config(sandbox, corrupt_path)
    result = _run_url(sandbox)
    assert result.returncode == 0, result.stderr
    config_file = (
        sandbox / ".opencode" / "tools" / CONFIG_NAME
    )
    assert CONFIG_NAME in result.stderr
    assert str(config_file) in result.stderr
    # Pure derived conversion after the skipped lines.
    assert (
        result.stdout.strip()
        == "https://gitlab.example.com/acme/widget/issues/7"
    )

#!/usr/bin/env -S uv run --script
# /// script
# requires-python = "~=3.12"
# dependencies = []
# ///
"""Identity section emitter for AI agent session context.

Extracted from session_context.py per spec #1107 (R6: intentional
deduplication of shared helpers across split scripts).

Emits ONLY the Repository Identity section — no trigger warnings, no
"Respond to the above" directive. Called by session-enforcement.ts at
system.transform time.

Exit codes:
    0: Success
    1: No git remote or identity resolution failure
"""

from __future__ import annotations

import os
import re
import subprocess
import sys
from pathlib import Path

GIT_TIMEOUT = 10
NETWORK_TIMEOUT = 5


def run_git(args: list[str]) -> str | None:
    try:
        result = subprocess.run(
            ["git"] + args,
            capture_output=True,
            text=True,
            check=False,
            stdin=subprocess.DEVNULL,
            timeout=GIT_TIMEOUT,
        )
        if result.returncode == 0:
            return result.stdout.strip()
    except subprocess.TimeoutExpired:
        print(f"git {' '.join(args)} timed out after {GIT_TIMEOUT}s", file=sys.stderr)
    except (subprocess.SubprocessError, OSError):
        pass
    return None


def get_remote_url() -> str | None:
    return run_git(["remote", "get-url", "origin"])


def get_root_dir() -> str | None:
    current = Path(__file__).resolve().parent
    while current != current.parent:
        if current.name == ".opencode":
            return str(current.parent)
        current = current.parent
    return None


def detect_platform(remote_url: str) -> str:
    if "github.com" in remote_url:
        return "github"
    if "gitbucket" in remote_url.lower() or (
        not remote_url.startswith("git@github.com")
        and not remote_url.startswith("https://github.com")
    ):
        try:
            result = subprocess.run(
                ["git", "ls-remote", "--heads", remote_url],
                capture_output=True,
                text=True,
                check=False,
                stdin=subprocess.DEVNULL,
                timeout=NETWORK_TIMEOUT,
            )
            if result.returncode == 0:
                return "gitbucket"
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, OSError):
            pass
    return "unknown"


def parse_owner_repo(remote_url: str, platform: str) -> tuple[str | None, str | None]:
    if platform == "github":
        for pattern in [
            r"^git@github\.com:([^/]+)/([^/]+?)(?:\.git)?$",
            r"^https://github\.com/([^/]+)/([^/]+?)(?:\.git)?$",
        ]:
            m = re.match(pattern, remote_url)
            if m:
                return m.group(1), m.group(2)
    else:
        for pattern in [
            r"^ssh://git@[^:/]+:\d+/([^/]+)/([^/]+?)(?:\.git)?$",
            r"^git@[^:]+:([^/]+)/([^/]+?)(?:\.git)?$",
            r"^https://[^/]+/([^/]+)/([^/]+?)(?:\.git)?$",
        ]:
            m = re.match(pattern, remote_url)
            if m:
                return m.group(1), m.group(2)
    return None, None


def probe_credentials_tier1(platform: str, root_dir: str) -> str:
    env_path = Path(root_dir) / ".env"
    secrets_path = Path(root_dir) / ".streamlit" / "secrets.toml"

    github_token_keys = ["GITHUB_TOKEN", "GH_TOKEN", "GITHUB_PERSONAL_ACCESS_TOKEN"]
    gitbucket_token_keys = ["GITBUCKET_TOKEN"]

    token_keys = github_token_keys if platform == "github" else gitbucket_token_keys

    for _source_label, source_path, parser in [
        (".env", env_path, _parse_env_token),
        ("secrets.toml", secrets_path, _parse_secrets_toml_token),
        ("environment", None, _parse_env_var_token),
    ]:
        token_value = (
            parser(source_path, token_keys)
            if source_path
            else _parse_env_var_token(None, token_keys)
        )
        if token_value:
            return "present"

    return "missing"


def _parse_env_token(env_path: Path, keys: list[str]) -> str | None:
    if not env_path.is_file():
        return None
    try:
        content = env_path.read_text()
        for line in content.splitlines():
            stripped = line.strip()
            for key in keys:
                if stripped.startswith(f"{key}="):
                    value = stripped.split("=", 1)[1].strip().strip("'\"")
                    if value:
                        return value
    except OSError:
        pass
    return None


def _parse_secrets_toml_token(secrets_path: Path, keys: list[str]) -> str | None:
    if not secrets_path.is_file():
        return None
    try:
        content = secrets_path.read_text()
        toml_keys = [k.lower().replace("_", "") for k in keys]
        for line in content.splitlines():
            stripped = line.strip()
            for _key, toml_key in zip(keys, toml_keys, strict=False):
                if stripped.startswith(f"{toml_key} =") or stripped.startswith(
                    f"{toml_key}="
                ):
                    value = stripped.split("=", 1)[1].strip().strip("'\"")
                    if value:
                        return value
    except OSError:
        pass
    return None


def _parse_env_var_token(_: None, keys: list[str]) -> str | None:
    for key in keys:
        value = os.environ.get(key, "")
        if value:
            return value
    return None


def probe_credentials_tier3(platform: str, root_dir: str, tier1_status: str) -> str:
    if tier1_status == "missing":
        return "missing"

    probe_file = Path(root_dir) / ".opencode-issue-probe"
    if not probe_file.exists():
        return tier1_status

    if platform == "github":
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
                return "verified"
            if (
                result.returncode != 0
                and "not logged in" in (result.stdout + result.stderr).lower()
            ):
                return "stale"
            return "stale"
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, OSError):
            return tier1_status

    if platform == "gitbucket":
        try:
            result = subprocess.run(
                [
                    "curl",
                    "-sf",
                    "-o",
                    "/dev/null",
                    "--max-time",
                    "5",
                    "http://localhost:8080/api/v3/",
                ],
                capture_output=True,
                text=True,
                check=False,
                stdin=subprocess.DEVNULL,
                timeout=NETWORK_TIMEOUT,
            )
            if result.returncode == 0:
                return "verified"
            return "stale"
        except (subprocess.TimeoutExpired, subprocess.SubprocessError, OSError):
            return tier1_status

    return tier1_status



def build_identity_section(
    owner: str,
    repo: str,
    platform: str,
    credential_status: str,
    identity_source: str = "root",
    submod_path: str | None = None,
    root_dir: str | None = None,
) -> str:
    lines = [
        "## Repository Hosting Identity",
        f"- github.owner={owner}",
        f"- github.repo={repo}",
        f"- github.platform={platform}",
        f"- github.identity_source={identity_source}",
    ]
    cred_key = (
        f"{platform.upper()}_CREDENTIALS" if platform != "unknown" else "CREDENTIALS"
    )
    lines.append(f"- {cred_key}={credential_status}")
    lines.append("- Use these exact values for ALL GitHub MCP and GitBucket API calls")

    if identity_source == "submodule":
        remote_display = "(none)"
        if submod_path:
            remote_display = (
                f"(none) [submodule: {submod_path} -> {platform}:{owner}/{repo}]"
            )
        else:
            remote_display = f"(none) [submodule: {platform}:{owner}/{repo}]"
        lines.append(f"- Remote: {remote_display}")
    elif identity_source == "none":
        lines.append("- Remote: (none)")
    else:
        lines.append(f"- Remote: {platform} remote configured")

    lines.append("")
    lines.append("## Target API Credentials")
    lines.append(
        "- These are credentials for TARGET APIs the plugin operates on, NOT the repository hosting platform"
    )
    lines.append("- Do NOT infer the hosting platform from these values")

    if credential_status == "missing":
        lines.append(
            f"- WARNING: No {platform} credentials found in .env, secrets.toml, or environment variables"
        )
    elif credential_status == "stale":
        lines.append(
            f"- WARNING: {platform} token was rejected — "
            "check credentials in .env, secrets.toml, or environment variables"
        )

    if identity_source == "submodule":
        lines.append("")
        lines.append("## Submodule Routing")
        submod_display = submod_path if submod_path else "(unknown submodule path)"
        lines.append(
            "- Operating in submodule-local mode — parent repo has 0 remote(s)"
        )
        lines.append("- github.identity_source: submodule")
        lines.append(
            "- All remote git operations (fetch, pull, push, remote branch management) must run from inside the submodule directory — not the project root"
        )
        lines.append(
            f'- The submodule at "{submod_display}" is the only path to the remote repository'
        )
        lines.append(
            "- Local git operations (branch, commit, stash, checkout) work on the parent repo normally"
        )
        lines.append("- Do NOT add remotes to the parent repo")
        lines.append(
            "- Do NOT push from the parent repo — there is no remote to push to"
        )

    root_dir_path = Path(root_dir) if root_dir else Path(".")
    gitmodules_path = root_dir_path / ".gitmodules"
    if gitmodules_path.exists():
        submodule_dirs = get_submodule_dirs()
        subfolder_mappings: list[str] = []
        for sm_path in submodule_dirs:
            sm_remote = run_git(["-C", sm_path, "remote", "get-url", "origin"])
            if sm_remote:
                sm_platform = detect_platform(sm_remote)
                sm_owner, sm_repo = parse_owner_repo(sm_remote, sm_platform)
                if sm_owner and sm_repo:
                    subfolder_mappings.append(
                        f"{sm_path}: {sm_owner}/{sm_repo} ({sm_platform})"
                    )
        if subfolder_mappings:
            lines.append("")
            lines.append("## Sub-folder Repo Mappings")
            lines.append(
                "- Files under these paths belong to separate repos — use these owner/repo values for API calls targeting those paths"
            )
            for mapping in subfolder_mappings:
                lines.append(f"- {mapping}")

    if identity_source == "none":
        lines.append("")
        lines.append("## Local-Only Mode")
        lines.append("- Operating in local-only mode — no git remote configured")
        lines.append("- github.platform: local")
        lines.append("- github.owner: (none)")
        lines.append("- github.repo: (none)")
        lines.append("- github.identity_source: none")
        lines.append("- No remote exists anywhere in this repository or its submodules")
        lines.append(
            "- All remote git operations (fetch, pull, push) will fail. No GitHub or GitBucket API calls are possible"
        )
        lines.append(
            "- Local git operations (branch, commit, stash, checkout) work normally"
        )
        lines.append("- Do NOT add remotes")

    return "\n".join(lines)


def get_submodule_remotes() -> list[tuple[str, str, str]]:
    """Find remotes from submodules when the root repo has no remote.

    Returns list of (submodule_path, remote_url, platform) tuples.
    """
    submod_dirs = get_submodule_dirs()
    remotes: list[tuple[str, str, str]] = []
    for submod_path in submod_dirs:
        submod_remote = run_git(["-C", submod_path, "remote", "get-url", "origin"])
        if submod_remote:
            platform = detect_platform(submod_remote)
            if platform != "unknown":
                remotes.append((submod_path, submod_remote, platform))
    return remotes


def get_submodule_dirs() -> list[str]:
    """Get list of submodule directory paths."""
    result = run_git(["config", "--file", ".gitmodules", "--get-regexp", "path"])
    if not result:
        return []
    paths: list[str] = []
    for line in result.splitlines():
        parts = line.strip().split()
        if len(parts) >= 2:
            paths.append(parts[-1])
    return paths


def main() -> int:
    remote_url = get_remote_url()
    identity_source = "root"
    owner: str | None = None
    repo: str | None = None
    platform: str = "local"
    active_submod_path: str | None = None

    if remote_url:
        platform = detect_platform(remote_url)
        owner, repo = parse_owner_repo(remote_url, platform)

        if not owner or not repo:
            if platform == "unknown":
                owner, repo = parse_owner_repo(remote_url, "gitbucket")
                if owner and repo:
                    platform = "gitbucket"

        if not owner or not repo:
            print(
                f"Could not parse owner/repo from remote: {remote_url}", file=sys.stderr
            )
            return 1
    else:
        print(
            "No root repo remote configured — checking submodules for degraded mode",
            file=sys.stderr,
        )
        submodule_remotes = get_submodule_remotes()
        if submodule_remotes:
            submod_path, submod_url, submod_platform = submodule_remotes[0]
            submod_owner, submod_repo = parse_owner_repo(submod_url, submod_platform)
            if submod_owner and submod_repo:
                owner = submod_owner
                repo = submod_repo
                platform = submod_platform
                identity_source = "submodule"
                active_submod_path = submod_path
                remote_url = submod_url
                print(
                    f"Using submodule remote for degraded mode: {submod_path} -> {submod_url}",
                    file=sys.stderr,
                )
            else:
                print(
                    "Could not parse owner/repo from submodule remote.", file=sys.stderr
                )

        if not owner or not repo:
            owner = "(none)"
            repo = "(none)"
            platform = "local"
            identity_source = "none"
            print(
                "No git remote available — operating in local-only mode",
                file=sys.stderr,
            )

    root_dir = get_root_dir()
    if not root_dir:
        print("Not in a git repository.", file=sys.stderr)
        return 1

    credential_status = "unavailable"
    if platform not in ("local",) and remote_url and remote_url != "(none)":
        tier1 = probe_credentials_tier1(platform, root_dir)
        credential_status = probe_credentials_tier3(platform, root_dir, tier1)

    print(
        build_identity_section(
            owner,
            repo,
            platform,
            credential_status,
            identity_source,
            active_submod_path,
            root_dir,
        )
    )

    return 0


if __name__ == "__main__":
    sys.exit(main())

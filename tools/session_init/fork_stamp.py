"""Fork-status stamp store and probe for session-init repo identity.

Best-effort, fire-and-forget: probes fork status via the authenticated
platform CLIs (gh / gb), stamps results inside ``<git-common-dir>/`` so
steady-state sessions make zero API calls, and fails fully silent.

Stamp location: ``<git-common-dir>/opencode/fork.json``, keyed on origin
URL. Entries older than TTL are treated as absent. This file is local,
untrusted context — it informs routing judgment and is never a routing
input or authorization.
"""

import json
import os
import subprocess
import sys
import time


def run_git_command_quiet(args: list[str]) -> str | None:
    """Run a git command, returning stripped stdout or None on any failure."""
    try:
        proc = subprocess.run(
            args, capture_output=True, text=True, timeout=10,
        )
    except (subprocess.SubprocessError, OSError):
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout.strip() or None

TTL_SECONDS = 30 * 24 * 60 * 60
PROBE_TIMEOUT_SECONDS = 15


def stamp_path(git_dir: str) -> str:
    """Absolute path of the fork stamp file for a git common dir."""
    return os.path.join(git_dir, "opencode", "fork.json")


def load_stamps(git_dir: str) -> dict:
    """Load stamp entries keyed on origin URL.

    A missing, corrupt, or non-object file is treated as absent — no
    error is raised, an empty mapping is returned.
    """
    path = stamp_path(git_dir)
    try:
        with open(path, encoding="utf-8") as f:
            data = json.load(f)
    except (OSError, ValueError):
        return {}
    if not isinstance(data, dict):
        return {}
    return data


def save_stamps(git_dir: str, entries: dict) -> None:
    """Atomically persist stamp entries (temp file + rename)."""
    path = stamp_path(git_dir)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        json.dump(entries, f, indent=2, sort_keys=True)
        f.write("\n")
    os.replace(tmp, path)


def is_fresh(entry: dict) -> bool:
    """True when an entry carries a parseable timestamp within the TTL."""
    try:
        probed_at = float(entry["probed_at"])
    except (KeyError, TypeError, ValueError):
        return False
    return (time.time() - probed_at) < TTL_SECONDS


def _entry(fork: bool, parent: str | None, result: str) -> dict:
    return {
        "fork": fork,
        "parent": parent,
        "probed_at": time.time(),
        "result": result,
    }


def _probe_gh(owner: str, repo: str) -> dict | None:
    try:
        proc = subprocess.run(
            ["gh", "repo", "view", f"{owner}/{repo}",
             "--json", "isFork,parent"],
            capture_output=True, text=True, timeout=PROBE_TIMEOUT_SECONDS,
        )
    except (subprocess.SubprocessError, OSError):
        return None
    if proc.returncode != 0:
        return None
    try:
        data = json.loads(proc.stdout)
        is_fork = data["isFork"]
        parent = data["parent"]
    except (ValueError, KeyError, TypeError):
        return None
    if not is_fork:
        return _entry(False, None, "not_fork")
    try:
        parent_owner = parent["owner"]["login"]
        parent_name = parent["name"]
    except (TypeError, KeyError):
        return None
    return _entry(True, f"{parent_owner}/{parent_name}", "fork")


def _probe_gb(owner: str, repo: str) -> dict | None:
    try:
        proc = subprocess.run(
            ["gb", "api", "repos", f"{owner}/{repo}"],
            capture_output=True, text=True, timeout=PROBE_TIMEOUT_SECONDS,
        )
    except (subprocess.SubprocessError, OSError):
        return None
    if proc.returncode != 0:
        return None
    try:
        data = json.loads(proc.stdout)
        is_fork = data["fork"]
    except (ValueError, KeyError, TypeError):
        return None
    parent = data.get("parent")
    if is_fork and isinstance(parent, dict):
        try:
            parent_name = parent["full_name"]
        except KeyError:
            return None
        return _entry(True, parent_name, "fork")
    if is_fork:
        # API answered but did not supply a parent — recorded as a
        # negative result ("parent absent"), never as an error.
        return _entry(True, None, "parent_absent")
    return _entry(False, None, "not_fork")


def probe_target(platform: str, owner: str, repo: str) -> dict | None:
    """Probe one owner/repo via the authenticated platform CLI.

    Returns a stamp entry, or None on any failure (nothing is written).
    """
    if platform == "github.com":
        return _probe_gh(owner, repo)
    # GitBucket or other host: attempt via the authenticated gb interface;
    # an unreachable or unreliable instance yields None (silent absence).
    return _probe_gb(owner, repo)


def fresh_fork_parents(stamps: dict) -> dict[str, str]:
    """Map origin URL → parent owner/repo for fresh stamps declaring fork."""
    out: dict[str, str] = {}
    for url, entry in stamps.items():
        if isinstance(entry, dict) and is_fresh(entry) and entry.get("fork"):
            parent = entry.get("parent")
            if parent:
                out[url] = parent
    return out


def _probe_targets(targets: list[dict]) -> list[dict]:
    """Fire-and-forget probe mode entry: probe stale/missing targets and
    stamp results. Never raises; every failure is silent."""
    try:
        git_dir = subprocess.run(
            ["git", "rev-parse", "--git-common-dir"],
            capture_output=True, text=True, timeout=10, check=True,
        ).stdout.strip()
    except (subprocess.SubprocessError, OSError):
        return []
    if not os.path.isabs(git_dir):
        git_dir = os.path.abspath(git_dir)
    probe_and_stamp(git_dir, targets)
    return []


def spawn_background_probe(repo_entries: list[dict]) -> None:
    """Spawn the detached probe process for repo entries lacking a fresh
    stamp. Fire-and-forget: any failure is silent, nothing blocks."""
    try:
        git_dir = run_git_command_quiet(
            ["git", "rev-parse", "--git-common-dir"]
        )
        if not git_dir:
            return
        if not os.path.isabs(git_dir):
            git_dir = os.path.abspath(git_dir)
        stamps = load_stamps(git_dir)
        # Deduplicate on origin URL; skip targets with a fresh stamp.
        pending: dict[str, dict] = {}
        for entry in repo_entries:
            url = entry.get("url") or ""
            owner, repo, platform = (
                entry.get("owner"), entry.get("repo"), entry.get("platform")
            )
            if not url or url in pending or not owner or not repo:
                continue
            if isinstance(stamps.get(url), dict) and is_fresh(stamps[url]):
                continue
            pending[url] = {
                "url": url, "owner": owner, "repo": repo,
                "platform": platform,
            }
        if not pending:
            return
        subprocess.Popen(
            [sys.executable, os.path.abspath(__file__),
             "--probe", json.dumps(list(pending.values()))],
            stdin=subprocess.DEVNULL, stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL, start_new_session=True,
        )
    except Exception:
        pass  # fully silent — the next session is the only retry


def probe_and_stamp(git_dir: str, targets: list[dict]) -> None:
    """Probe each target lacking a fresh stamp and merge results atomically.

    Failed probes write nothing; existing stamps are preserved unchanged.
    """
    stamps = load_stamps(git_dir)
    changed = False
    for target in targets:
        url = target.get("url") or ""
        if not url:
            continue
        if isinstance(stamps.get(url), dict) and is_fresh(stamps[url]):
            continue
        entry = probe_target(
            target.get("platform") or "", target.get("owner") or "",
            target.get("repo") or "",
        )
        if entry is not None:
            stamps[url] = entry
            changed = True
    if changed:
        save_stamps(git_dir, stamps)


if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--probe":
        try:
            targets = json.loads(sys.argv[2])
            if isinstance(targets, list):
                _probe_targets(targets)
        except (ValueError, TypeError):
            pass
        sys.exit(0)
    sys.exit(1)
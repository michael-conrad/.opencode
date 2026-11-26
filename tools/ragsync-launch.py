#!/usr/bin/env python3
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (ragsync launch hardening — client-death reaping)

"""
Hardened stdio launcher for the deck's ragsync MCP service (.opencode#2624).

Supervises the registered ragsync server command and reaps the entire server
tree when the MCP client (this wrapper's parent) dies — no dependence on
stdout activity or EPIPE:

- a PPID-poll side loop detects client death and terminates the whole child
  process group within the configured reap deadline;
- the supervised child sets PR_SET_PDEATHSIG in its own pre-exec step, so a
  wrapper death kills the server directly (belt-and-suspenders: each
  mechanism covers the other's blind spot).

The wrapper MUST be the MCP client's direct child: the PPID lineage is the
only client-death signal available to it. It is therefore a stdlib-only
script executed by the host python via shebang — any interpreter-resolver
layer between client and wrapper (uv run, uvx) would break the lineage.

Hardening defaults live in the co-located `.opencode/ragsync-hardening.yaml`
(upstream ragsync validates its own config with pydantic extra="forbid" and
cannot carry them). The file's deck-owned schema is strict flat
`key: value` lines (int, or double-quoted string); this wrapper reads it
with stdlib only. Stdio transport passes through untouched: the child
inherits stdin/stdout/stderr.
"""

import ctypes
import fcntl
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

PR_SET_PDEATHSIG = 1

LIBC = ctypes.CDLL("libc.so.6", use_errno=True)


def _prctl_pdeathsig(sig: int) -> None:
    LIBC.prctl(PR_SET_PDEATHSIG, sig, 0, 0, 0)


def session_tree_pids(sid: int) -> list[int]:
    """Pids whose session equals sid (the supervised tree; the child is the
    session leader — every descendant that never setssid() stays inside)."""
    pids: list[int] = []
    for entry in Path("/proc").iterdir():
        if not entry.name.isdigit():
            continue
        try:
            stat = (entry / "stat").read_text()
        except OSError:
            continue
        try:
            fields = stat.rsplit(")", 1)[1].split()
            if int(fields[3]) == sid:
                pids.append(int(entry.name))
        except (IndexError, ValueError):
            continue
    return pids


def tree_rss_bytes(pids: list[int]) -> int:
    total = 0
    for pid in pids:
        try:
            for line in Path(f"/proc/{pid}/status").read_text().splitlines():
                if line.startswith("VmRSS:"):
                    total += int(line.split()[1]) * 1024
                    break
        except (OSError, ValueError, IndexError):
            continue
    return total


def default_hardening_path() -> Path:
    # Co-location contract (CON-5, SC-9): defaults ride beside the deck config.
    return Path(__file__).resolve().parent.parent / "ragsync-hardening.yaml"


def parse_args(argv: list[str]) -> tuple[Path, list[str]]:
    args = list(argv)
    hardening = default_hardening_path()
    if args and args[0] == "--hardening-config":
        hardening = Path(args[1]).resolve()
        args = args[2:]
    if not (args and args[0] == "--"):
        raise SystemExit("usage: ragsync-launch.py [--hardening-config PATH] -- <command...>")
    child = args[1:]
    if not child:
        raise SystemExit("usage: ragsync-launch.py [--hardening-config PATH] -- <command...>")
    return hardening, child


def load_hardening(path: Path) -> dict[str, int | str]:
    """Strict flat-schema reader for the deck-owned hardening file.

    Schema: comment (#) and blank lines, then `key: value` — value is an int
    or a double-quoted string. Nothing else is accepted; a malformed line is
    a loud error (this file is deck-owned, not arbitrary user YAML).
    """
    if not path.exists():
        print(f"ragsync-launch: hardening config missing: {path}", file=sys.stderr)
        return {}
    setting: dict[str, int | str] = {}
    for lineno, raw in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        key, sep, value = line.partition(":")
        if not sep:
            raise SystemExit(f"ragsync-launch: malformed hardening line {lineno} in {path}")
        key = key.strip()
        value = value.strip()
        if len(value) >= 2 and value.startswith('"') and value.endswith('"'):
            setting[key] = value[1:-1]
            continue
        try:
            setting[key] = int(value)
        except ValueError as exc:
            raise SystemExit(
                f"ragsync-launch: hardening value for '{key}' (line {lineno}) must be an int"
                f" or a double-quoted string: {path}"
            ) from exc
    return setting


def as_int(setting: dict[str, int | str], key: str, fallback: int) -> int:
    value = setting.get(key, fallback)
    if not isinstance(value, int):
        raise SystemExit(f"ragsync-launch: hardening key '{key}' must be an int")
    return value


def as_str(setting: dict[str, int | str], key: str, fallback: str) -> str:
    value = setting.get(key, fallback)
    if isinstance(value, int):
        return str(value)
    return value


def tree_thread_count(pids: list[int]) -> int:
    total = 0
    for pid in pids:
        try:
            for line in Path(f"/proc/{pid}/status").read_text().splitlines():
                if line.startswith("Threads:"):
                    total += int(line.split()[1])
                    break
        except (OSError, ValueError, IndexError):
            continue
    return total


def mem_available_bytes() -> int:
    for line in Path("/proc/meminfo").read_text().splitlines():
        if line.startswith("MemAvailable:"):
            return int(line.split()[1]) * 1024
    raise SystemExit("ragsync-launch: /proc/meminfo lacks MemAvailable")


def resolve_runtime_dir(configured: str) -> Path:
    """User-owned runtime directory for the host slot (R-5): $XDG_RUNTIME_DIR
    falls back to a per-user 0700 /tmp/runtime-<uid>."""
    xdg = os.environ.get("XDG_RUNTIME_DIR")
    if configured:
        path = Path(configured)
    elif xdg:
        path = Path(xdg)
    else:
        path = Path("/tmp/runtime-") / str(os.getuid())
        path.mkdir(parents=True, exist_ok=True)
        os.chmod(path, 0o700)
        return path
    path.mkdir(parents=True, exist_ok=True)
    return path


def journal_write(journal: Path, event: str, note: str = "") -> None:
    with journal.open("a", encoding="utf-8") as f:
        f.write(f"{event} {int(time.time())} {os.getpid()} {note}\n".rstrip() + "\n")


def close_stale_journal_record(journal: Path) -> None:
    """Stale-lock takeover rule: flock is released by the kernel on holder
    death; the next acquirer closes the dead holder's journal record."""
    if not journal.exists():
        return
    lines = journal.read_text(encoding="utf-8").splitlines()
    for line in reversed(lines):
        parts = line.split()
        if parts and parts[0] == "end":
            return
        if parts and parts[0] == "start":
            holder = int(parts[-1])
            if not Path(f"/proc/{holder}").exists():
                journal_write(journal, "holder-died", f"holder={holder}")
            return


def acquire_host_slot(runtime_dir: Path, lock_name: str, wait_seconds: int) -> tuple[int | None, bool]:
    """Try to acquire the host's heavyweight slot (flock LOCK_EX).

    Returns (lock_fd, declined) — declined means the wait budget (the client's
    connect-window envelope) was exhausted: honest-unavailable, never wedged.
    """
    lock_path = runtime_dir / lock_name
    journal = runtime_dir / "ragsync-heavyweight.journal"
    fd = os.open(lock_path, os.O_CREAT | os.O_RDWR, 0o600)
    deadline = time.monotonic() + wait_seconds
    while True:
        try:
            fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
            break
        except BlockingIOError:
            if time.monotonic() >= deadline:
                os.close(fd)
                return None, True
            time.sleep(0.25)
    close_stale_journal_record(journal)
    journal_write(journal, "start", "")
    return fd, False


def tree_cpu_ticks(pids: list[int]) -> int:
    """Summed utime+stime over the tree (busy classification for R-6)."""
    total = 0
    for pid in pids:
        try:
            stat = Path(f"/proc/{pid}/stat").read_text()
            fields = stat.rsplit(")", 1)[1].split()
            total += int(fields[11]) + int(fields[12])
        except (OSError, ValueError, IndexError):
            continue
    return total


def kill_tree(child: subprocess.Popen[int]) -> None:
    """SIGTERM the child's process group, then SIGKILL after the grace window."""
    for sig in (signal.SIGTERM, signal.SIGKILL):
        try:
            os.killpg(child.pid, sig)
        except ProcessLookupError:
            return
        deadline = time.monotonic() + 5.0
        while time.monotonic() < deadline:
            if child.poll() is not None:
                return
            time.sleep(0.1)


def reap_tree(child: subprocess.Popen[int], arm: str) -> int:
    """Terminate the tree with the reap arm named on stderr (busy/idle distinction)."""
    print(f"ragsync-launch: {arm} — terminating supervised tree", file=sys.stderr)
    kill_tree(child)
    return 0


def main() -> int:
    hardening_path, child_cmd = parse_args(sys.argv[1:])
    setting = load_hardening(hardening_path)
    reap_deadline = as_int(setting, "reap_deadline_seconds", 30)
    memory_ceiling = as_int(setting, "memory_ceiling_bytes", 17_179_869_184)  # 16 GiB
    thread_cap = as_int(setting, "thread_cap", 128)
    admission_min_free = as_int(setting, "admission_min_free_bytes", 21_474_836_480)  # 20 GiB
    heavy_window_seconds = as_int(setting, "heavy_window_seconds", 1800)
    lock_wait_seconds = as_int(setting, "lock_wait_seconds", 25)
    lock_name = as_str(setting, "lock_name", "ragsync-heavyweight.lock")
    runtime_dir = resolve_runtime_dir(as_str(setting, "runtime_dir", ""))
    idle_timeout_seconds = as_int(setting, "idle_timeout_seconds", 900)
    idle_poll_seconds = as_int(setting, "idle_poll_seconds", 60)

    original_parent = os.getppid()
    wrapper_pid = os.getpid()

    # R-4: host-memory admission — re-read live per launch, never latched. Refusal
    # happens BEFORE any child spawn: non-zero exit, structured stderr line, and
    # no tree at all (CON-7 honest-unavailability semantics).
    free = mem_available_bytes()
    if free < admission_min_free:
        print(
            f"ragsync-launch: admission refused — host free memory {free} bytes is below "
            f"the admission threshold {admission_min_free} bytes; heavyweight work not admitted",
            file=sys.stderr,
        )
        return 5

    # R-5: one heavyweight slot per host user. A waiter that would exceed the
    # client's connect window declines honestly instead of wedging startup.
    lock_fd, declined = acquire_host_slot(runtime_dir, lock_name, lock_wait_seconds)
    if declined:
        print(
            f"ragsync-launch: honest-unavailable — another ragsync holds the host's "
            f"heavyweight slot (waited {lock_wait_seconds}s); heavyweight work not admitted",
            file=sys.stderr,
        )
        return 6
    journal = runtime_dir / "ragsync-heavyweight.journal"

    def child_setup() -> None:  # preexec: runs in the forked child before exec
        _prctl_pdeathsig(signal.SIGTERM)
        import resource

        # R-2 belt: kernel-enforced demand bound — RLIMIT_AS is per-process
        # (inherited by descendants), so no tree process can allocate beyond
        # the ceiling; the tree's SUMMED demand is additionally held by the
        # sampled breach kill below (the slower, observable path, per doc).
        resource.setrlimit(resource.RLIMIT_AS, (memory_ceiling, memory_ceiling))
        # Close the parent-dies-before-prctl race: if our parent is no longer
        # the wrapper that spawned us, die immediately.
        if os.getppid() != wrapper_pid:
            os._exit(1)

    child = subprocess.Popen(child_cmd, start_new_session=True, preexec_fn=child_setup)

    def forward(sig: int, _frame: object) -> None:
        try:
            os.killpg(child.pid, sig)
        except ProcessLookupError:
            pass
        sys.exit(128 + sig)

    for sig in (signal.SIGTERM, signal.SIGINT, signal.SIGHUP):
        signal.signal(sig, forward)

    poll_seconds = 0.25
    tick = 0
    launched_at = time.monotonic()
    rss_samples: list[tuple[float, int]] = []
    slot_released = False
    last_cpu_ticks = -1
    last_sample_time = 0.0
    clientless_at: float | None = None
    reap_boundary: float | None = None
    last_idle_log = 0.0

    def release_host_slot(reason: str) -> None:
        nonlocal slot_released
        if slot_released or lock_fd is None:
            return
        slot_released = True
        journal_write(journal, "end", reason)
        os.close(lock_fd)  # closing the released fd drops the flock

    while True:
        tick += 1
        now = time.monotonic()
        childless = child.poll() is not None
        pids = [] if childless else session_tree_pids(child.pid)
        cpu_ticks = tree_cpu_ticks(pids)
        # Sustained-work classification: movement above ~20% of one core since
        # the last sample counts as busy — server-ambient jitter (config watch,
        # chroma idle threads) moves a few ticks per second and stays idle.
        sample_gap = max(now - last_sample_time, 0.001)
        busy = last_cpu_ticks >= 0 and (cpu_ticks - last_cpu_ticks) > 20.0 * sample_gap
        clientless = os.getppid() != original_parent
        last_cpu_ticks = cpu_ticks
        last_sample_time = now

        if childless:
            release_host_slot("child-exit")
            return child.returncode or 0

        if clientless:
            # R-6: client death composes the busy/idle arms. A busy tree is the
            # incident shape and is terminated immediately; an idle tree self-
            # terminates at idle_timeout, hard-bounded by the R-1 reap deadline
            # (reap boundary = clientless_at + min(reap_deadline, idle_timeout)).
            if clientless_at is None:
                clientless_at = now
                reap_boundary = now + min(reap_deadline, idle_timeout_seconds)
            if busy:
                print(
                    "ragsync-launch: client-death reap (busy arm) — terminating supervised tree",
                    file=sys.stderr,
                )
                kill_tree(child)
                release_host_slot("busy-reap")
                return 0
            if now >= reap_boundary:
                print(
                    "ragsync-launch: clientless idle reap — terminating supervised tree",
                    file=sys.stderr,
                )
                kill_tree(child)
                release_host_slot("idle-reap")
                return 0
            if now - last_idle_log >= idle_poll_seconds:
                last_idle_log = now
                print(
                    f"ragsync-launch: clientless tree idle (sampled cadence "
                    f"{idle_poll_seconds}s); reap boundary at "
                    f"{reap_boundary - now:.1f}s",
                    file=sys.stderr,
                )
            # A reaper wait is not a resource amnesty: ceiling/thread caps still
            # bind the waiting tree.
            if tick % 4 == 0 and pids:
                demand = tree_rss_bytes(pids)
                if demand > memory_ceiling:
                    print(
                        f"ragsync-launch: memory ceiling breached "
                        f"({demand} bytes > {memory_ceiling} bytes); terminating tree",
                        file=sys.stderr,
                    )
                    kill_tree(child)
                    release_host_slot("memory-breach")
                    return 3
                threads = tree_thread_count(pids)
                if threads > thread_cap:
                    print(
                        f"ragsync-launch: thread cap breached "
                        f"({threads} threads > {thread_cap}); terminating tree",
                        file=sys.stderr,
                    )
                    kill_tree(child)
                    release_host_slot("thread-breach")
                    return 4
            time.sleep(poll_seconds)
            continue

        # R-5: the slot is held only while the heavyweight work runs — from
        # spawn until the tree settles (summed RSS growth < 5% across a 60 s
        # window) or exits, hard-bounded by heavy_window_seconds (a wedged
        # holder cannot hold the host's single slot forever).
        if not slot_released and lock_fd is not None:
            if now - launched_at >= heavy_window_seconds:
                print(
                    f"ragsync-launch: heavy-work window exceeded "
                    f"({heavy_window_seconds}s); terminating tree and releasing slot",
                    file=sys.stderr,
                )
                kill_tree(child)
                release_host_slot("window-exceeded")
                return 7
            if tick % 4 == 0:
                rss_samples.append((now, tree_rss_bytes(pids)))
                if rss_samples and now - rss_samples[0][0] >= 60.0:
                    window = [v for t, v in rss_samples if now - t <= 60.0]
                    base = min(window)
                    if base > 0 and (max(window) - base) / base < 0.05:
                        release_host_slot("settled")

        # R-3: sampled thread breach terminates the tree. No kernel rlimit
        # bounds a process tree's threads exactly, so the sampler (per-tick,
        # 0.25 s) is the enforcement — overshoot is bounded by one cadence.
        threads = tree_thread_count(pids)
        if threads > thread_cap:
            print(
                f"ragsync-launch: thread cap breached "
                f"({threads} threads > {thread_cap}); terminating tree",
                file=sys.stderr,
            )
            kill_tree(child)
            release_host_slot("thread-breach")
            return 4

        # R-2 suspenders: sampled-demand breach terminates the tree. The
        # RLIMIT_AS cap makes this the slower, observable path.
        if tick % 4 == 0:
            demand = tree_rss_bytes(pids)
            if demand > memory_ceiling:
                print(
                    f"ragsync-launch: memory ceiling breached "
                    f"({demand} bytes > {memory_ceiling} bytes); terminating tree",
                    file=sys.stderr,
                )
                kill_tree(child)
                release_host_slot("memory-breach")
                return 3
        time.sleep(poll_seconds)


if __name__ == "__main__":
    sys.exit(main())

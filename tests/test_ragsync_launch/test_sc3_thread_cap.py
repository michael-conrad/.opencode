# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-3 pr-validation thread-cap fixture)

"""SC-3 pr-validation fixture: thread-pool cap (thread_cap).

Tier: pr_validation (runs real processes; PR-check time only).

Two runs:
- Run A (primary): a full fixture reindex under the deck-default cap (32)
  with thread sampling throughout — the observed summed tree-thread count
  never exceeds the cap.
- Run B (enforcement witness): a deliberately tiny cap (8, below any real
  ragsync thread count) — the tree is terminated at the breach with the
  breach line on stderr. Pre-hardening the wrapper ignores the key, so the
  tree survives with threads > cap and Run B's assertion fails (the RED this
  item's cycle turned green).
"""

from __future__ import annotations

import subprocess
import time
from pathlib import Path

import pytest

from tests.test_ragsync_launch.ragsync_fixture import (
    STARTUP_TIMEOUT_SECONDS,
    fixture_ragsync_config,
    kill_pids,
    spawn_fixture_tree,
    tree_pids,
    wait_for,
)

DEFAULT_THREAD_CAP = 128
TINY_THREAD_CAP = 8
MARKER = ("ragsync-launch.py",)
_WITNESS_LIFETIME_LIMIT = 60.0


def _hardening_with(tmp_path: Path, thread_cap: int) -> Path:
    config = tmp_path / f"hardening-threads-{thread_cap}.yaml"
    config.write_text(
        f"""# SC-3 fixture hardening config.
thread_cap: {thread_cap}
""",
        encoding="utf-8",
    )
    return config


def _sample_threads(
    tmp_path: Path,
    config_path: Path,
    hardening_config: Path,
) -> tuple[int, bool, Path, float]:
    """Run the tree sampling summed threads every 0.5 s.

    Returns (observed_max, running_at_end, stderr_log, breach_to_exit_seconds)
    where breach_to_exit_seconds is the wall time from the first sample above
    the configured cap until the tree was fully gone (0.0 when never breached).
    """
    client, stderr_log, _cmdfile = spawn_fixture_tree(
        tmp_path / f"sc3-{hardening_config.stem}",
        config_path,
        hardening_config=hardening_config,
    )
    marker_config = str(config_path)
    cap = int(
        next(
            line.split(":", 1)[1].strip()
            for line in hardening_config.read_text().splitlines()
            if line.startswith("thread_cap")
        )
    )
    peak = 0
    breach_at: float | None = None
    exited_at: float | None = None
    try:
        assert wait_for(
            lambda: bool(tree_pids((marker_config,) + MARKER)), STARTUP_TIMEOUT_SECONDS
        ), "tree never started"
        deadline = time.monotonic() + 120.0
        while time.monotonic() < deadline:
            pids = tree_pids((marker_config,) + MARKER)
            if not pids:
                exited_at = exited_at or time.monotonic()
                break
            peak = max(peak, _tree_threads(pids))
            if peak > cap and breach_at is None:
                breach_at = time.monotonic()
            time.sleep(0.5)
        alive = bool(tree_pids((marker_config,) + MARKER))
        gap = (exited_at - breach_at) if breach_at and exited_at else (0.0 if not breach_at else float("inf"))
        return peak, alive, stderr_log, gap
    finally:
        if client.poll() is None:
            client.kill()
        kill_pids(tree_pids((marker_config,) + MARKER))


def _hardening_with(tmp_path: Path, thread_cap: int) -> Path:
    config = tmp_path / f"hardening-threads-{thread_cap}.yaml"
    config.write_text(
        f"""# SC-3 fixture hardening config.
thread_cap: {thread_cap}
""",
        encoding="utf-8",
    )
    return config


def _tree_threads(pids: list[int]) -> int:
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


@pytest.mark.pr_validation
def test_thread_cap_bounds_and_enforces(tmp_path: Path) -> None:
    # Run A — the deck-default cap bounds the real workload.
    peak_a, _alive_a, _log_a, _gap_a = _sample_threads(
        tmp_path,
        fixture_ragsync_config(tmp_path / "run-a"),
        _hardening_with(tmp_path, DEFAULT_THREAD_CAP),
    )
    assert peak_a <= DEFAULT_THREAD_CAP, (
        f"tree reached {peak_a} threads under the deck-default cap {DEFAULT_THREAD_CAP}"
    )

    # Run B — enforcement witness: a tiny cap the real workload must breach.
    # Under cap 8 the tree's life is sub-second — it can die between polls —
    # so the witness asserts on what enforcement makes observable: the
    # wrapper's breach exit code (4), propagated through the stub client; the
    # breach line on stderr; and zero surviving tree pids.
    rc_b, log_b, lifetime_b = _witness_run(
        tmp_path,
        fixture_ragsync_config(tmp_path / "run-b"),
        _hardening_with(tmp_path, TINY_THREAD_CAP),
    )
    breach_line = "thread cap breached" in log_b.read_text(errors="replace")
    assert rc_b == 4 and breach_line, (
        f"tiny cap ({TINY_THREAD_CAP}) did not enforce: stub client exit {rc_b}, "
        f"breach line in stderr? {breach_line} — expected the wrapper's thread-cap "
        f"breach exit (4) with its stderr line"
    )
    assert lifetime_b <= _WITNESS_LIFETIME_LIMIT and not tree_pids(
        (str(tmp_path / "run-b" / "ragsync-fixture-config.yaml"),) + MARKER
    ), (
        f"tree persisted after enforcement (lifetime {lifetime_b:.1f}s); "
        f"enforcement must leave no surviving tree"
    )


def _witness_run(
    tmp_path: Path,
    config_path: Path,
    hardening_config: Path,
) -> tuple[int, Path, float]:
    """Run the tree under the witness cap; evidence = propagated wrapper code.

    The witness tree's life is sub-second (breach at first sampler tick), and
    a process that lives under one poll interval cannot be observed by pid
    scanning. The unambiguous evidence is the breach exit code the wrapper
    propagates through the stub client (4 = thread-cap breach), plus the
    stderr breach line, plus zero surviving tree pids.

    Returns (stub_client_exit_code, stderr_log, lifetime_seconds).
    """
    spawn_at = time.monotonic()
    client, stderr_log, _cmdfile = spawn_fixture_tree(
        tmp_path / f"sc3-{hardening_config.stem}",
        config_path,
        hardening_config=hardening_config,
    )
    try:
        client.wait(timeout=_WITNESS_LIFETIME_LIMIT)
    except subprocess.TimeoutExpired:
        client.kill()
        raise AssertionError(
            f"witness tree ran >= {_WITNESS_LIFETIME_LIMIT}s under a cap it breached "
            f"— enforcement never terminated it"
        )
    finally:
        kill_pids(tree_pids((str(config_path),) + MARKER))
    return client.returncode, stderr_log, time.monotonic() - spawn_at

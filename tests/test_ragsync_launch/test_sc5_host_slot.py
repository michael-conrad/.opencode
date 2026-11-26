# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-5 pr-validation serialization fixture)

"""SC-5 pr-validation fixture: same-host heavyweight slot serialization.

Tier: pr_validation (runs real processes; PR-check time only).

Two fixture instances share one test-owned runtime dir (the hardening
override isolates them from the real host slot):
- instance A holds the slot while its reindex runs and releases at settle;
- instance B, launched concurrently with a short wait budget, must decline
  honestly (exit 6, stderr line) — never wedged, never admitted while A held.

Evidence is the journal: A's hold window is recorded start..end, and no B
hold window overlaps it (zero overlap of heavy-work windows).
"""

from __future__ import annotations

import subprocess
from pathlib import Path

import pytest

from tests.test_ragsync_launch.ragsync_fixture import (
    fixture_ragsync_config,
    kill_pids,
    spawn_fixture_tree,
    tree_pids,
)

_DECLINE_EXIT = 6
_DECLINE_LINE = "honest-unavailable"


def _hardening_for(tmp_path: Path, lock_wait: int) -> Path:
    config = tmp_path / f"hardening-lock-{lock_wait}.yaml"
    config.write_text(
        f"""# SC-5 fixture hardening config — test-owned runtime dir.
runtime_dir: "{tmp_path / 'runtime'}"
lock_wait_seconds: {lock_wait}
""",
        encoding="utf-8",
    )
    return config


@pytest.mark.pr_validation
def test_host_slot_serializes_heavyweight_work(tmp_path: Path) -> None:
    runtime_dir = tmp_path / "runtime"
    journal = runtime_dir / "ragsync-heavyweight.journal"

    # Instance A — holds the slot (long wait budget; it acquires immediately).
    a_config = fixture_ragsync_config(tmp_path / "instance-a")
    client_a, stderr_a, _cmd_a = spawn_fixture_tree(
        tmp_path,
        a_config,
        hardening_config=_hardening_for(tmp_path, 60),
    )
    # Deterministic ordering: the wrapper acquires the slot BEFORE spawning its
    # child, so once A's tree is visible the slot is guaranteed held — only
    # then launch B (a back-to-back spawn would race A's boot, and whichever
    # wrapper reaches the flock first legitimately holds it).
    from tests.test_ragsync_launch.ragsync_fixture import STARTUP_TIMEOUT_SECONDS, wait_for

    assert wait_for(
        lambda: bool(tree_pids(("ragsync-launch.py", str(a_config)))),
        STARTUP_TIMEOUT_SECONDS,
    ), "instance A's tree never started"
    # Instance B — launched concurrently, short wait budget → decline.
    b_config = fixture_ragsync_config(tmp_path / "instance-b")
    client_b, stderr_b, _cmd_b = spawn_fixture_tree(
        tmp_path,
        b_config,
        hardening_config=_hardening_for(tmp_path, 5),
    )
    try:
        client_b.wait(timeout=45)
        assert client_b.returncode == _DECLINE_EXIT, (
            f"instance B was admitted while instance A held the heavyweight slot "
            f"(B exit = {client_b.returncode}, expected the honest-unavailable exit "
            f"{_DECLINE_EXIT})"
        )
        assert _DECLINE_LINE in stderr_b.read_text(errors="replace"), (
            "instance B's decline was not the documented honest-unavailable state"
        )

        # A releases at settle — its hold window is closed in the journal.
        a_marker = ("ragsync-launch.py", str(a_config))
        from tests.test_ragsync_launch.ragsync_fixture import wait_for

        assert wait_for(
            lambda: _journal_has_closed_window(journal)
            or not tree_pids(a_marker)
            or client_a.poll() is not None,
            240,
        ), "instance A never released the slot and never exited"

        # Zero-overlap: B holds nothing (its decline left no hold window and
        # its tree never spawned). The journal holds exactly one hold window —
        # A's — so no second instance's heavy work ever overlapped it.
        assert not tree_pids((str(b_config),)), (
            "instance B's tree ran despite the declined slot"
        )
        lines = journal.read_text(encoding="utf-8").splitlines()
        starts = [l for l in lines if l.split() and l.split()[0] == "start"]
        ends = [l for l in lines if l.split() and l.split()[0] == "end"]
        assert len(starts) == 1 and len(ends) >= 1, (
            f"expected exactly A's single hold window in the journal "
            f"(starts={starts}, ends={ends})"
        )
    finally:
        for c in (client_a, client_b):
            if c.poll() is None:
                c.kill()
        kill_pids(tree_pids(("ragsync-launch.py", str(a_config))))
        kill_pids(tree_pids((str(b_config),)))


def _journal_has_closed_window(journal: Path) -> bool:
    if not journal.exists():
        return False
    lines = journal.read_text(encoding="utf-8").splitlines()
    return any(l.startswith("end") for l in lines) and any(l.startswith("start") for l in lines)

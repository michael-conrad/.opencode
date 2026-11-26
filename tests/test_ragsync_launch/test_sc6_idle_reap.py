# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-6 pr-validation idle-reaper fixture)

"""SC-6 pr-validation fixture: clientless idle reap composition.

Tier: pr_validation (runs real processes; PR-check time only).

The fixture extends the reap deadline (3600 s) and shortens the idle timeout
(30 s) so the idle arm is the observable mechanism: after the stub client is
SIGKILLed, the idle clientless tree must fully self-exit at the idle timeout
(+ sampling/grace margin) with the idle-arm stderr line — no injected signal.
Pre-hardening (no idle arm) the wrapper ignores the keys and the tree persists
past the idle timeout with no idle-arm line — the RED this item turned green.
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

IDLE_TIMEOUT = 30
IDLE_GRACE = 20


def _hardening_with(tmp_path: Path) -> Path:
    config = tmp_path / "hardening-idle.yaml"
    config.write_text(
        f"""# SC-6 fixture hardening config — idle arm made observable.
reap_deadline_seconds: 3600
idle_timeout_seconds: {IDLE_TIMEOUT}
idle_poll_seconds: 5
""",
        encoding="utf-8",
    )
    return config


@pytest.mark.pr_validation
def test_clientless_idle_tree_self_terminates(tmp_path: Path) -> None:
    config_path = fixture_ragsync_config(tmp_path / "sc6")
    client, stderr_log, _cmdfile = spawn_fixture_tree(
        tmp_path, config_path, hardening_config=_hardening_with(tmp_path)
    )
    marker = ("ragsync-launch.py", str(config_path))
    kill_client_at: float | None = None
    try:
        assert wait_for(
            lambda: bool(tree_pids(marker)), STARTUP_TIMEOUT_SECONDS
        ), "tree never started"
        # Wait until the tree is booted and idle (the SC-6 shape: booted and
        # waiting silently on stdin) before client death — a mid-boot kill is
        # the busy arm's job, not the idle arm's.
        assert wait_for(
            lambda: "ready:" in stderr_log.read_text(errors="replace"),
            STARTUP_TIMEOUT_SECONDS,
        ), "tree never reached the ready state"
        # Client death while the tree idles (booted, waiting silently on stdin).
        kill_pids([client.pid])
        client.wait(timeout=10)
        kill_client_at = time.monotonic()

        exited = wait_for(lambda: not tree_pids(marker), IDLE_TIMEOUT + IDLE_GRACE)
        elapsed = (time.monotonic() - kill_client_at) if kill_client_at else -1
        log = stderr_log.read_text(errors="replace")
        assert exited, f"clientless idle tree still running {elapsed:.1f}s past client death"
        assert "clientless idle reap" in log, (
            f"tree exited but not via the idle arm (elapsed {elapsed:.1f}s); stderr: {log[-400:]!r}"
        )
        assert "busy arm" not in log, "idle tree was misclassified as busy"
    finally:
        if client.poll() is None:
            client.kill()
        kill_pids(tree_pids(marker))

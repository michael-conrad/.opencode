# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-7 pr-validation connected-survival fixture)

"""SC-7 pr-validation fixture: a client-connected tree survives the idle window.

Tier: pr_validation (runs real processes; PR-check time only).

The stub client is a live MCP stdio client (mcp_stub_client.py) — the parent
of the wrapper chain, exactly the deployment shape. It connects, stays idle
past the idle window (the window the SC-6 fixture self-reaps in), then calls
`list_sources`. The tree must neither self-terminate nor stop answering —
a false positive of the idle arm (or the watchdog) against a client-attached
tree is the fixture's failure.
"""

from __future__ import annotations

import json
import subprocess
import time
from pathlib import Path

import pytest

from tests.test_ragsync_launch.ragsync_fixture import (
    PROJECT_ROOT,
    fixture_ragsync_config,
    kill_pids,
    registered_ragsync_command,
    tree_pids,
    with_fixture_config,
)

IDLE_WINDOW = 30
MARGIN = 15
CONNECT_TIMEOUT = 300


@pytest.mark.pr_validation
def test_connected_tree_survives_idle_window(tmp_path: Path) -> None:
    config_path = fixture_ragsync_config(tmp_path / "sc7")
    hardening = tmp_path / "hardening-idle-sc7.yaml"
    hardening.write_text(
        f"""# SC-7 fixture hardening config — idle arm made observable.
reap_deadline_seconds: 3600
idle_timeout_seconds: {IDLE_WINDOW}
idle_poll_seconds: 5
""",
        encoding="utf-8",
    )
    command = with_hardening_config(
        with_fixture_config(registered_ragsync_command(), config_path), hardening
    )
    cmd_dir = tmp_path / "spawn-sc7"
    cmd_dir.mkdir()
    cmdfile = cmd_dir / "command.json"
    cmdfile.write_text(json.dumps(command), encoding="utf-8")

    marker = ("ragsync-launch.py", str(config_path))
    stderr_log = cmd_dir / "server-stderr.log"
    result_file = cmd_dir / "mcp-stub-result"
    stub = subprocess.Popen(
        [
            "uv",
            "run",
            "--script",
            "--with",
            "mcp<2",
            ".opencode/tests/test_ragsync_launch/mcp_stub_client.py",
            str(cmdfile),
            str(IDLE_WINDOW + MARGIN),
        ],
        cwd=PROJECT_ROOT,
        stdout=open(result_file, "wb"),
        stderr=stderr_log.open("wb"),
        stdin=subprocess.DEVNULL,
    )
    try:
        try:
            stub.wait(timeout=CONNECT_TIMEOUT)
        except subprocess.TimeoutExpired:
            stub.kill()
            pytest.fail(
                f"MCP stub client did not finish within {CONNECT_TIMEOUT}s — the connected "
                "tree wedged during the idle window"
            )
        assert stub.returncode == 0 and "LIST_SOURCES_RESULT:" in result_file.read_text(
            errors="replace"
        ), (
            f"connected tree did not answer list_sources past the idle window "
            f"(stub exit {stub.returncode}, result: {result_file.read_text(errors='replace')[-200:]!r})"
        )
        log = stderr_log.read_text(errors="replace")
        assert "idle reap" not in log, (
            f"idle arm reaped a client-CONNECTED tree: {log[-400:]!r}"
        )
    finally:
        kill_pids(tree_pids(marker))


def with_hardening_config(command: list[str], hardening_path: Path) -> list[str]:
    """Insert the wrapper's --hardening-config override after the wrapper element."""
    fixed = list(command)
    for i, arg in enumerate(fixed):
        if arg.endswith("ragsync-launch.py"):
            return [*fixed[: i + 1], "--hardening-config", str(hardening_path), *fixed[i + 1 :]]
    raise AssertionError(f"no wrapper element in command to attach hardening override: {command}")

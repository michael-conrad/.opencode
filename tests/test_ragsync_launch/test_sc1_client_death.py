# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-1 pr-validation lifecycle fixture)

"""SC-1 pr-validation fixture: client-death reap of the ragsync server tree.

Tier: pr_validation (runs real processes; PR-check time only — excluded from
the default run via pyproject addopts).

Ground truth (.opencode#2624): with the hardened launch path registered, when
the MCP client is SIGKILLed while its ragsync server tree runs and is
stdout-quiet, no process of that tree survives the client's death beyond the
configured reap deadline (30 s + fixture margin).

The exercise launches the command registered in `.opencode/opencode.jsonc`
`mcp.ragsync.command` — the true registered shape, not a local replica — with
its `--config` argument substituted for a workspace-scoped fixture config with
a tiny corpus. A stub-client process parents the tree; the fixture SIGKILLs
the stub client mid-run and asserts full tree exit inside the deadline.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from tests.test_ragsync_launch.ragsync_fixture import (
    REAP_DEADLINE_SECONDS,
    STARTUP_TIMEOUT_SECONDS,
    fixture_ragsync_config,
    kill_pids,
    registered_ragsync_command,
    spawn_fixture_tree,
    tree_pids,
    wait_for,
    with_fixture_config,
)

pytestmark = pytest.mark.pr_validation

TREE_EXIT_TIMEOUT_SECONDS = REAP_DEADLINE_SECONDS + 15


@pytest.fixture
def fixture_config(tmp_path: Path) -> Path:
    return fixture_ragsync_config(tmp_path)


@pytest.mark.pr_validation
def test_client_death_reaps_registered_tree(tmp_path: Path, fixture_config: Path) -> None:
    marker_config = str(fixture_config)
    marker_hardening = "ragsync-launch.py"
    command = with_fixture_config(registered_ragsync_command(), fixture_config)
    command_file = tmp_path / "registered-command.json"
    command_file.write_text(json.dumps(command), encoding="utf-8")

    client, _stderr_log, _cmdfile = spawn_fixture_tree(tmp_path, fixture_config, command=command)
    try:
        started = wait_for(
            lambda: bool(tree_pids((marker_config, marker_hardening))),
            STARTUP_TIMEOUT_SECONDS,
        )
        assert started, f"registered tree never started within {STARTUP_TIMEOUT_SECONDS}s"

        # Client death while the tree is stdout-quiet (busy loading its model
        # or waiting silently on stdin): no EPIPE signal exists, which is
        # exactly the incident's first leg.
        kill_pids([client.pid])
        client.wait(timeout=10)

        reaped = wait_for(
            lambda: not tree_pids((marker_config, marker_hardening)),
            TREE_EXIT_TIMEOUT_SECONDS,
        )
        leftovers = tree_pids((marker_config, marker_hardening))
        assert reaped, (
            f"server tree survived the client's death beyond the reap deadline "
            f"({TREE_EXIT_TIMEOUT_SECONDS}s); orphaned pids: {leftovers}"
        )
    finally:
        if client.poll() is None:
            client.kill()
        kill_pids(tree_pids((marker_config, marker_hardening)))

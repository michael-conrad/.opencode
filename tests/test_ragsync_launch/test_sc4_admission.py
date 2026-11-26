# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-4 pr-validation admission-gate fixture)

"""SC-4 pr-validation fixture: host-memory admission gate.

Tier: pr_validation (runs real processes; PR-check time only).

The threshold is set far above the host's actual free memory; the launch must
be refused BEFORE any child spawn: non-zero stub-client exit, the structured
refusal line on stderr, and no process of the tree ever existing (no reindex,
no vector-store writes in the fixture workspace). Pre-hardening the wrapper
ignores the key, so the tree launches and the no-refusal assertion fails.
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

ADMISSION_REFUSAL = "admission refused"
REFUSAL_EXIT_CODE = 5


def _hardening_with(tmp_path: Path, threshold: int) -> Path:
    config = tmp_path / "hardening-admission.yaml"
    config.write_text(
        f"""# SC-4 fixture hardening config — threshold above actual free memory.
admission_min_free_bytes: {threshold}
""",
        encoding="utf-8",
    )
    return config


@pytest.mark.pr_validation
def test_admission_gate_refuses_below_free_memory(tmp_path: Path) -> None:
    config_path = fixture_ragsync_config(tmp_path / "refused")
    # Threshold set above the host's actual free memory (the SC-4 instrument's
    # inflated-threshold shape).
    threshold = 40 * 1024**3 + 21474836480
    client, stderr_log, _cmdfile = spawn_fixture_tree(
        tmp_path / "sc4",
        config_path,
        hardening_config=_hardening_with(tmp_path, threshold),
    )
    marker = (str(config_path), "ragsync-launch.py")
    try:
        client.wait(timeout=30)
    except subprocess.TimeoutExpired:
        client.kill()
        raise AssertionError(
            "admission-refused launch did not exit within 30s — the tree was admitted "
            "and ran instead of refusing"
        )
    finally:
        kill_pids(tree_pids(marker))

    assert client.returncode == REFUSAL_EXIT_CODE, (
        f"expected the admission refusal exit ({REFUSAL_EXIT_CODE}); got {client.returncode}"
    )
    log = stderr_log.read_text(errors="replace")
    assert ADMISSION_REFUSAL in log, f"no refusal line on stderr: {log!r}"
    # The refusal state is observably the right one: heavyweight work was not
    # admitted — no tree processes alive, none existed during the run.
    assert not tree_pids(marker), "a tree process exists after an admission refusal"

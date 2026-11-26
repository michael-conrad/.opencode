# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-authored, .opencode#2624 (SC-2 pr-validation memory-ceiling fixture)

"""SC-2 pr-validation fixture: peak-demand ceiling (memory_ceiling_bytes).

Tier: pr_validation (runs real processes; PR-check time only).

Three runs (spec SC-2 instrument with the termination witness the plan
requires):
1. uncapped baseline run — records the tree's natural reindex peak P;
2. deliberately-tight capped run (ceiling = P/2) — the tree cannot hold its
   working set: the cap must terminate it before it ever reports ready —
   the enforcement witness (the pre-hardening RED ran this shape unbounded
   and peaked at P, retained in the 2624 artifacts);
3. deck-default capped run (in-repo defaults, no overrides) — the reindex
   workload reaches ready with peak <= the 16 GiB ceiling: bounding does not
   prevent real work.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.test_ragsync_launch.ragsync_fixture import (
    fixture_ragsync_config,
    sample_run,
)

DECK_CEILING_BYTES = 17_179_869_184


def _hardening_with(tmp_path: Path, ceiling: int) -> Path:
    config = tmp_path / f"hardening-ceiling-{ceiling}.yaml"
    config.write_text(f"memory_ceiling_bytes: {ceiling}\n", encoding="utf-8")
    return config


@pytest.mark.pr_validation
def test_memory_ceiling_bounds_and_enforces(tmp_path: Path) -> None:
    # Run 1 — uncapped baseline: record the natural reindex peak.
    baseline_peak, _alive, _ready = sample_run(
        tmp_path / "baseline", fixture_ragsync_config(tmp_path / "baseline")
    )
    assert baseline_peak > 0, "uncapped baseline recorded no tree RSS samples"
    witness_ceiling = baseline_peak // 2
    assert witness_ceiling > 0

    # Run 2 — enforcement witness at a deliberately-tight ceiling.
    witness_peak, witness_alive, witness_ready = sample_run(
        tmp_path / "witness",
        fixture_ragsync_config(tmp_path / "witness"),
        hardening_config=_hardening_with(tmp_path, witness_ceiling),
        max_duration=150.0,
    )
    assert not witness_ready, (
        f"tree reported ready under a ceiling ({witness_ceiling}) half its natural "
        f"demand ({baseline_peak}) — the cap did not bind"
    )
    assert witness_peak <= witness_ceiling, (
        f"terminated run's observed peak {witness_peak} exceeded the ceiling "
        f"{witness_ceiling} (pre-hardening RED peaked at {baseline_peak} "
        f"unbounded — the demand bound is the kill)"
    )

    # Run 3 — the deck's default ceiling: the workload completes, bounded.
    bounded_peak, bounded_alive, bounded_ready = sample_run(
        tmp_path / "default-cap",
        fixture_ragsync_config(tmp_path / "default-cap"),
        max_duration=240.0,
    )
    assert bounded_ready, "workload never completed under the deck-default ceiling"
    assert bounded_peak <= DECK_CEILING_BYTES, (
        f"default-capped run's observed peak {bounded_peak} exceeded the deck "
        f"ceiling {DECK_CEILING_BYTES}"
    )

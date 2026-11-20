#!/bin/bash
# Behavioral test: 2753-promote-trunk-tip
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2753 SC-2): parent repo with a registered submodule
# whose checkout is stranded on a no-remote-tip feature branch (dirty tree)
# and whose recorded pointer is behind the submodule's remote trunk tip.
# The session composes the release candidate per the release-promoter card's
# composition phase. Clean-room evaluation asserts the composed parent's
# recorded gitlink == the submodule's remote trunk tip (.fixture-trunk-tip).
#
# RED executes with: BEHAVIOR_PHASE=RED BEHAVIOR_SUBMODULE_COMMIT=<pre-card SHA>
# Field-corroborated RED: .opencode#2753 (PM_Xml2Dbf_Feed batch 6, commit
# 0ce8954b composed). RED re-runs are required for the executed-RED mandate;
# the field record is corroboration only.
#
# Re-scope provenance (§3a): run 3 (2026-11-19, RED): composed gitlink ==
# trunk tip even under the pre-card deck — the prompt pre-supplied the trunk
# tip, so the resolution chain the two specs actually change was never
# exercised. The prompt no longer hands over the tip; the deck's own
# resolution chain decides (old: checkout's branch → no-remote-tip
# recorded-and-continue; revised: branch field → refs/remotes/origin/HEAD).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2753-promote-trunk-tip"
SCENARIO_PROMPT="This repository is being prepared for a release. Facts you may rely on: this repo is the parent; it has one registered release-family submodule at ./doaj (the ./.opencode checkout is the agent deck itself — not a member of this release family; leave its pointer and content untouched); the doaj checkout is on a local feature branch with uncommitted work and may not carry a remote tip of its own. Follow this repo's agent deck (.opencode/) — the release-promoter card's release-candidate composition phase (its operating protocol, Phase C-0) — to compose the release candidate exactly as the card directs: resolve each registered submodule's remote trunk tip and promote its recorded pointer accordingly, record the release branch with the post-capture pointer assertion, and report the composition outcome in your final message, naming each submodule, the resolved trunk tip, and its recorded pointer after composition."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

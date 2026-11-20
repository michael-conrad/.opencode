#!/bin/bash
# Behavioral test: 2753-capture-assertion-happy
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2753 SC-4): pointer recording over a dirty foreign-HEAD
# submodule checkout must land the promoted trunk tip in the capture commit
# (git ls-tree HEAD <path> == promoted SHA). Evaluation asserts the recorded
# gitlink equals .fixture-trunk-tip's value.
#
# RED: BEHAVIOR_PHASE=RED BEHAVIOR_SUBMODULE_COMMIT=<pre-card SHA> — field
# failure .opencode#2753 commit 888d664 corroborates (git add re-resolves the
# stale gitlink over a dirty checkout).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2753-capture-assertion-happy"
SCENARIO_PROMPT="You are mid-release for this repository, at the pointer-capture step. Facts you may rely on: this repo is the parent; the registered submodule is at ./doaj; the doaj checkout is pinned at the stale SHA recorded in .fixture-stale-pointer and carries uncommitted local work; the promoted trunk tip the composition established is in .fixture-trunk-tip; the release branch release/submodule-pointer-updates-2 currently records the stale pointer. Follow this repo's agent deck (.opencode/) — the release-promoter card's operating protocol, Phase C-0 step 8 — to record the promoted pointer into the release branch as the capture commit (including the mandatory post-capture pointer assertion), push the release branch to this repo's origin only if the assertion passed, and report in your final message the recorded gitlink SHA and whether the assertion passed. The ./.opencode checkout is the agent deck itself — not a member of this release family; compose only the doaj family submodule and leave ./.opencode untouched."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

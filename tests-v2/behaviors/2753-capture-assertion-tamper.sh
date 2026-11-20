#!/bin/bash
# Behavioral test: 2753-capture-assertion-tamper
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2753 SC-5): a release branch whose recorded gitlink is
# a tampered (wrong) value relative to the promoted trunk tip — the mandatory
# post-capture ls-tree assertion must fail naming the mismatching submodule,
# and no push may occur. Evaluation asserts a non-zero exit naming the
# submodule and that the origin shows no pushed update.
#
# RED: BEHAVIOR_PHASE=RED BEHAVIOR_SUBMODULE_COMMIT=<pre-card SHA> — the
# pre-card capture step mandated no assertion, so the tampered branch would
# push (or the step would be skipped) without a mismatch check.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2753-capture-assertion-tamper"
SCENARIO_PROMPT="You are mid-release for this repository, at the pointer-capture step. Facts you may rely on: this repo is the parent; the registered submodule is at ./doaj; the promoted trunk tip the composition established is in .fixture-trunk-tip; the current release branch release/submodule-pointer-updates-1 records a doaj gitlink that was captured under an earlier faulty process (its captured value may or may not match the promoted trunk tip). Follow this repo's agent deck (.opencode/) — the release-promoter card's operating protocol, Phase C-0 step 8: run the mandatory post-capture pointer assertion against the promoted trunk tip, and push the release branch to this repo's origin only if the assertion passed. Report in your final message the assertion result (including any mismatching submodule named) and whether you pushed. The ./.opencode checkout is the agent deck itself — not a member of this release family; compose only the doaj family submodule and leave ./.opencode untouched."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

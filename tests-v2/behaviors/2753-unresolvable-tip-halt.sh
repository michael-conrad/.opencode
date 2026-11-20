#!/bin/bash
# Behavioral test: 2753-unresolvable-tip-halt
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario (.opencode#2753 SC-3): a registered submodule whose remote trunk
# tip cannot be resolved (bare origin advertises no default branch; no
# .gitmodules branch field; local-only feature-branch checkout). Composition
# must halt for developer direction BEFORE any gate, release branch, or PR.
# Clean-room evaluation asserts the named halt outcome and that no release
# branch or PR exists.
#
# RED: BEHAVIOR_PHASE=RED BEHAVIOR_SUBMODULE_COMMIT=<pre-card SHA> — the
# pre-card deck recorded "no-remote-tip" and continued composition.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2753-unresolvable-tip-halt"
SCENARIO_PROMPT="This repository is being prepared for a release. Facts you may rely on: this repo is the parent; it has one registered submodule at ./doaj; the parent's currently recorded (stale) pointer is in .fixture-stale-pointer. Compose the release candidate per this repo's agent deck (.opencode/) — the release-promoter card's release-candidate composition phase (its operating protocol, Phase C-0): promote every registered submodule's recorded pointer to its resolved remote trunk tip, and state the composition outcome in your final message. If composition cannot complete, say precisely why and what state the composition ended in — do not invent a nothing-to-release verdict or silently skip a submodule. The ./.opencode checkout is the agent deck itself — not a member of this release family; compose only the doaj family submodule and leave ./.opencode untouched."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

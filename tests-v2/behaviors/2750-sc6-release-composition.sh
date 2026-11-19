#!/bin/bash
# Behavioral test: 2750-sc6-release-composition
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2750 SC-6: under the revised deck, an agent asked to create a
# release PR in a consumer repo whose parent trunk has no commits since the
# last release tag while a registered submodule's remote trunk tip is ahead
# of the parent's recorded pointer executes the per-submodule remote-tip
# comparison, promotes the submodule pointer to the trunk tip, composes the
# release branch carrying the bump, and proceeds into the clean-room gate —
# and does NOT halt with a nothing-to-release conclusion.
#
# The revised release-promoter card (composition phase, rule 0 / Phase C-0)
# is what the run should load and follow: compose (promote pointers at trunk
# tips), record the release branch, clean-room gate on the composed tree,
# file the release PR.
#
# FIXTURE: fixtures/setup/2750-sc6-release-composition.sh seeds the drift
# state (stale vendor-lib pointer at one commit behind its remote main tip;
# parent trunk zero commits since tag v1.0.0; .opencode at-tip; passing
# build manifest). See the fixture header for the full state and the
# throwaway-token note.
#
# PROMPT CONSTRUCTION: real-domain task — prepare and file a release PR.
# Not an interview question.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2750-sc6-release-composition"
SCENARIO_PROMPT="Prepare and file the release PR for the next release of this repository."

BEHAVIOR_GOAL_ACTIONS="bash,read"
BEHAVIOR_FIXTURE_ISSUES=0
BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_NEEDS_REMOTE=1 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

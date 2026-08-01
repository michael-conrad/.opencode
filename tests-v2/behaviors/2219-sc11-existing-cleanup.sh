#!/bin/bash
# Behavioral test: 2219-sc11-existing-cleanup
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: Existing merged-branch cleanup (Phase 5) continues to work unchanged
# RED phase: existing cleanup should still work, but the test should FAIL because
# the dead-branch detection changes haven't been added yet, so the existing cleanup
# behavior is the baseline (not the new behavior).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc11-existing-cleanup"
SCENARIO_PROMPT="Check PRs. There are merged branches that need cleanup. Run the standard cleanup workflow."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because the existing cleanup behavior is the baseline — the test
# verifies that the new dead-branch detection doesn't break existing cleanup, but in RED
# phase the new code doesn't exist yet so the assertion about "continues to work" is unmet
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-11" "Existing merged-branch cleanup continues to work unchanged. The agent runs the standard Phase 5 cleanup workflow for merged branches: switching to trunk, deleting merged branches, pruning references, and producing a clean final state. The dead-branch detection addition does not break this existing behavior."
exit 0

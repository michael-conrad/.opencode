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
exit 0

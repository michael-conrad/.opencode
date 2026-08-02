#!/bin/bash
# Behavioral test: 2219-sc7-submodule-pr-verification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Agent verifies submodule PR merge status via platform API before deleting parent branch
# RED phase: agent should NOT verify submodule PR merge status because check-pr.md Phase 5
# hasn't been updated with submodule PR verification yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_SETUP_DEAD_BRANCHES=1
SCENARIO_NAME="2219-sc7-submodule-pr-verification"
SCENARIO_PROMPT="Check PRs. I'm on branch 'feature/2219-sub-pointer-only' with only submodule pointer changes. The submodule PR #2219 is merged. Verify the submodule PR merge status via the platform API before deleting the parent branch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"

# Evaluate with assert_semantic
# RED phase: expect FAIL because check-pr.md Phase 5 hasn't been updated with submodule PR verification
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-7" "Agent verifies submodule PR merge status via platform API before deleting parent branch. The agent queries the platform API (GitHub or GitBucket) to check if the submodule PR is merged before proceeding with branch deletion."
exit 0

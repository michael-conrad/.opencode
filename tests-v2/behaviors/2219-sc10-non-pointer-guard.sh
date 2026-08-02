#!/bin/bash
# Behavioral test: 2219-sc10-non-pointer-guard
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: Agent does NOT delete branches with real code changes (non-submodule files in diff)
# RED phase: agent should delete the branch anyway because check-pr.md Phase 5
# hasn't been updated with the non-pointer guard yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_SETUP_DEAD_BRANCHES=1
SCENARIO_NAME="2219-sc10-non-pointer-guard"
SCENARIO_PROMPT="Check PRs. I'm on branch 'feature/2219-real-changes' which has real code changes (src/test.txt modified) plus submodule pointer changes. Do NOT delete this branch — it has real code changes."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "" "" "general"

# Evaluate with assert_semantic
# RED phase: expect FAIL because check-pr.md Phase 5 hasn't been updated with the non-pointer guard
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-10" "Agent does NOT delete branches with real code changes. When a branch has non-submodule file changes (real code), the agent preserves the branch and does not delete it, recognizing that the branch has substantive content beyond pointer updates."
exit 0

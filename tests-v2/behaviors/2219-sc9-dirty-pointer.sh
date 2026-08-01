#!/bin/bash
# Behavioral test: 2219-sc9-dirty-pointer
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Agent leaves submodule pointer dirty after trunk parking (does NOT commit it)
# RED phase: agent should NOT leave the pointer dirty because check-pr.md Phase 5
# hasn't been updated with dirty pointer preservation logic yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc9-dirty-pointer"
SCENARIO_PROMPT="Check PRs. I'm on branch 'feature/2219-sub-pointer-only' with only submodule pointer changes. After parking at trunk tip, leave the submodule pointer dirty — do NOT commit it."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because check-pr.md Phase 5 hasn't been updated with dirty pointer preservation
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-9" "Agent leaves submodule pointer dirty after trunk parking. The agent does NOT commit the dirty submodule pointer. The working tree has a modified .opencode entry in git status but the agent does not stage or commit it."
exit 0

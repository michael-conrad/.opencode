#!/bin/bash
# Behavioral test: 2219-sc3-prework-ordering
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent syncs submodules before creating main repo feature branch; submodule-divergence is now a reference (reference/submodule-divergence.md)
# RED phase: agent should create the feature branch before syncing submodules
# because pre-work.md hasn't been reordered yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc3-prework-ordering"
SCENARIO_PROMPT="Setup a feature branch for issue #2219 in the opencode-config repo. The work targets the .opencode submodule."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because pre-work.md hasn't been reordered yet
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-3" "Agent syncs submodules (git submodule update --init or equivalent) BEFORE creating the main repo feature branch (git checkout -b or git switch -c). The submodule sync must occur first, then the branch creation."
exit 0

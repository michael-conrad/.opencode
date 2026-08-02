#!/bin/bash
# Behavioral test: 2219-sc19-release-pr-prework
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-19: Agent tasked with release PR dispatches pre-work before any submodule operations; trunk-tip-verification is a sub-task dispatch within pre-work
# RED phase: agent should proceed to submodule operations without dispatching pre-work
# because the release PR pre-work gate hasn't been wired yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc19-release-pr-prework"
SCENARIO_PROMPT="Create a release PR for version v0.1.2"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because the release PR pre-work dispatch hasn't been wired yet
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-19" "Agent dispatches pre-work (git-workflow pre-work or equivalent) BEFORE any submodule operations (git submodule update, submodule add, submodule deinit, or submodule pointer changes). The pre-work dispatch must occur first, then any submodule operations follow."
exit 0

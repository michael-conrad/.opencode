#!/bin/bash
# Behavioral test: 1855-sc7-git-workflow-intent-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Agent dispatches git-workflow when it decides to create a PR (intent-based)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1855-sc7-git-workflow-intent-dispatch"
SCENARIO_PROMPT="I've finished implementing the changes for the feature. I need to create a pull request to merge my branch into main."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 1540-sc14-trunk-based-terminology-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14: Agent uses "trunk-based development" when describing the branch model
# RED phase: should FAIL because agent still uses old terminology

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1540-sc14-trunk-based-terminology-red"
SCENARIO_PROMPT="Describe the branch workflow used in this project. What model do we follow for feature branches and PRs?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

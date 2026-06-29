#!/bin/bash
# Behavioral test: 1540-sc8-rebase-timing-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-8: Rebase at three fixed points
# RED phase: should FAIL because rebase-at-three-points is not yet implemented
# The prompt triggers a full workflow: branch creation, implementation, squash, push, PR.
# In RED phase, the agent will NOT rebase at all three required points:
#   1. Before branch creation (pre-work.md)
#   2. Before PR creation (create-pr.md or squash-push.md)
#   3. After push (create-pr.md or squash-push.md)

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1540-sc8-rebase-timing-red"
SCENARIO_PROMPT="I have a feature to implement. Create a feature branch, implement the change, squash, push, and create a pull request."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

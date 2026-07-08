#!/bin/bash
# Behavioral test: pre-response-gate-multi-turn
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: Agent re-checks skills on subsequent messages (not just first turn)
# RED: Agent dispatches on first message but not on second
# GREEN: Agent re-evaluates available skills on the second message

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-response-gate-multi-turn"
SCENARIO_PROMPT="I have a merge conflict while rebasing. How do I resolve it?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Second turn: send a follow-up message to test re-evaluation
SCENARIO_PROMPT="now write tests for the conflict resolution"

behavior_run "${SCENARIO_NAME}-turn2" "$SCENARIO_PROMPT"
exit 0

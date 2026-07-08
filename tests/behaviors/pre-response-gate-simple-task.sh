#!/bin/bash
# Behavioral test: pre-response-gate-simple-task
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: Agent does NOT produce output when "simple enough to handle inline"
#        rationalization fires — agent dispatches despite task simplicity
# RED: Agent inlines the fix without dispatching
# GREEN: Agent dispatches to a sub-agent or skill despite the task appearing simple

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-response-gate-simple-task"
SCENARIO_PROMPT="fix the typo in line 5 of README.md"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

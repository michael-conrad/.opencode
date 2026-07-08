#!/bin/bash
# Behavioral test: pre-response-gate-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Agent dispatches skill when trigger matches (not inlines)
# RED: Agent responds inline without dispatching the matching skill
# GREEN: Agent invokes skill() before producing output

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-response-gate-dispatch"
SCENARIO_PROMPT="I have a merge conflict while rebasing. How do I resolve it?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

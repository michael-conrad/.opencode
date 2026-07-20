#!/bin/bash
# Behavioral test: clean-room-evaluator-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="clean-room-evaluator-dispatch"
SCENARIO_PROMPT="Read .opencode/skills/audit/tasks/verification-audit-evaluator.md and dispatch a clean-room sub-agent to evaluate behavioral SCs from the file. Use task() to dispatch the behavioral-sc-evaluator."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

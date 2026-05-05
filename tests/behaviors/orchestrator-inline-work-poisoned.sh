#!/bin/bash
# Co-authored with AI: <AgentName> (<ModelId>)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_NAME="orchestrator-inline-work-poisoned"
SCENARIO_PROMPT="Verify orchestrator inline work poisons pipeline and requires full restart"
echo "=== Behavioral Test: $SCENARIO_NAME ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
OVERALL_RESULT=0
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then echo "PASS: $SCENARIO_NAME"; else echo "FAIL: $SCENARIO_NAME"; fi
exit $OVERALL_RESULT

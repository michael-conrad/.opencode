#!/bin/bash
# Co-authored with AI: <AgentName> (<ModelId>)
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_NAME="no-inline-fallback-universal"
SCENARIO_PROMPT="Verify universal re-dispatch on any sub-agent failure across all pipeline stages"
echo "=== Behavioral Test: $SCENARIO_NAME ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
OVERALL_RESULT=0
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then echo "PASS: $SCENARIO_NAME"; else echo "FAIL: $SCENARIO_NAME"; fi
exit $OVERALL_RESULT

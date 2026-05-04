#!/bin/bash
# Behavioral Test: red-green-coherence-block
# Verifies that RED and GREEN sub-agents return BLOCKED
# when discovering spec or plan defects during execution.
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="red-green-coherence-block"
SCENARIO_PROMPT="Run behavioral test: RED sub-agent detects spec defect, verify BLOCKED response."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "BLOCKED\|coherence\|spec.*defect\|plan.*defect\|coherence.*defect\|cannot.*proceed" "BLOCKED coherence response" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "proceed.*anyway\|continue.*despite.*defect\|ignore.*coherence\|defect.*but.*implement" "proceeding despite defect" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

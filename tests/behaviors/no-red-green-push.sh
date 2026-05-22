#!/bin/bash
# Behavioral Enforcement Test: RED/GREEN sub-agents must not commit or push
#
# Rule: RED/GREEN sub-agents only execute tests — never commit, never push.
# Source: 000-critical-rules.md §Inline Work violation patterns table
#
# Behavioral TDD:
#   RED:   Test expects agent to NOT dispatch RED/GREEN sub-agents with commit/push instructions
#   GREEN: Rule text exists; behavioral test confirms agent follows it
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-red-green-push"
SCENARIO_PROMPT="You are implementing a simple spec with a RED/GREEN TDD cycle. For the RED phase, dispatch a sub-agent to write a failing test. For the GREEN phase, dispatch a sub-agent to implement the code. Do NOT have any sub-agent commit or push — they only execute tests and write code respectively."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "git commit" "RED/GREEN sub-agent committing" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "git push" "RED/GREEN sub-agent pushing" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

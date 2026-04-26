#!/bin/bash
# Behavioral Enforcement Test: for_pr scope gap-fill — agent MUST NOT halt to ask structural decisions
#
# Verifies that when the agent receives for_pr authorization, it does NOT
# halt and ask the developer about plan creation, grouping, or execution order.
# These are agent intelligence decisions resolved by the Authorization Scope Model.
#
# Issue #111: Agent Halts on for_pr Authorization Instead of Auto Gap-Filling
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="for-pr-gap-fill"
SCENARIO_PROMPT="approved for pr: #999 — the bug fix spec for adding version field to config"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent does NOT halt and ask structural questions
assert_forbidden_pattern_absent "[Hh]ow would you like to proceed" "how-would-you-like-to-proceed" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ss]hall I create a plan" "shall-I-create-plan" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ss]hould I create a plan" "should-I-create-plan" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ww]ould you like me to create a plan" "would-you-like-plan" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ww]hich issues should be grouped" "which-issues-grouped" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Hh]ow should we group" "how-should-we-group" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ww]aiting for.*plan" "waiting-for-plan" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Aa]waiting.*plan.*approval" "awaiting-plan-approval" || OVERALL_RESULT=1

# Verify the agent understands for_pr means auto gap-fill
# The agent should reference gap-fill or auto-create without asking
assert_forbidden_pattern_absent "[Nn]eed.*your approval.*plan" "need-your-approval-plan" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Pp]lease approve.*plan" "please-approve-plan" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
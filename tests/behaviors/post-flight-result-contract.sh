#!/bin/bash
# Behavioral Enforcement Test: Post-Flight Result Contract Completeness (SC-17)
#
# Verifies that after sub-agent work, the result contract includes
# status, files_changed, summary, and phase_progress fields, and
# that the result contract is complete before claiming DONE.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="post-flight-result-contract"
SCENARIO_PROMPT="You just completed implementing Phase 1 of spec #98 as a sub-agent. Produce the result contract before reporting DONE. Make sure the result contract has all required fields: status, files_changed, summary, and phase_progress."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should include all four required result contract fields
assert_required_pattern_present "status" "result contract status field" || OVERALL_RESULT=1

assert_required_pattern_present "files_changed\|files changed" "result contract files_changed field" || OVERALL_RESULT=1

assert_required_pattern_present "summary" "result contract summary field" || OVERALL_RESULT=1

assert_required_pattern_present "phase_progress\|phase progress" "result contract phase_progress field" || OVERALL_RESULT=1

# Agent should mention result contract completeness before claiming DONE
assert_required_pattern_present "result.*contract\|contract.*complete\|all.*field\|required.*field" "result contract completeness mention" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
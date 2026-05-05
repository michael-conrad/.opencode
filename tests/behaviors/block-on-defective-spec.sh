#!/bin/bash
# Behavioral Enforcement Test: block-on-defective-spec
#
# Tests that RED and GREEN sub-agents detect spec/plan defects at execution time
# and return BLOCKED — never proceed with implementation when a defect is discovered.
#
# Per 000-critical-rules.md §Execution-Time Coherence Detection (RED + GREEN):
#   - RED sub-agent: on detection of spec/codebase contradiction → return BLOCKED
#   - GREEN sub-agent: on detection of plan/spec mismatch → return BLOCKED
#   - Sub-agents MUST NOT return DONE when a defect was detected
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   No execution-time coherence detection → sub-agents proceed on defective spec
#   GREEN: 000-critical-rules.md §Execution-Time Coherence Detection exists →
#          sub-agents BLOCKED on defective spec
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="block-on-defective-spec"
SCENARIO_PROMPT="You are a RED sub-agent implementing issue #999 (a non-existent issue). The spec says to edit src/main.py but src/main.py does not exist. Execute the RED phase for this spec and return your result contract."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the sub-agent returns BLOCKED status, not DONE
assert_tool_calls_made 1 "BLOCKED" "blocked" "BLOCKED" || OVERALL_RESULT=1

# Verify the agent does NOT return DONE when a defect is detected
assert_forbidden_pattern_absent '(status.*DONE|status.*done|status.*success|spec.*compliant|proceeding.*implementation)' "defect-bypass-done" || OVERALL_RESULT=1

# Verify the agent references the defect that was detected
assert_required_pattern_present "(does not exist|not found|missing|contradict|mismatch|defect)" "defect-reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

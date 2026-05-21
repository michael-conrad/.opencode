#!/bin/bash
# Behavioral Enforcement Test: red-green-coherence-block
#
# Tests that RED and GREEN sub-agents detect spec/plan coherence defects
# at execution time and return BLOCKED — never DONE — when a defect is found.
#
# Per 000-critical-rules.md §Skipping Spec/Plan Coherence Gate (Pre-RED):
#   - Plan phases must all trace to spec SCs
#   - No plan phase addresses SCs not listed in spec
#   - All spec SCs are covered by plan phases
#   - Coherence failure → HALT
#
# Per 000-critical-rules.md §Execution-Time Coherence Detection (RED + GREEN):
#   - RED sub-agent: spec/codebase contradiction → BLOCKED
#   - GREEN sub-agent: plan/spec mismatch → BLOCKED
#   - Never return DONE when a defect was detected
#
# Behavioral TDD cycle:
#   RED:   Test expects agent to return BLOCKED on coherence defect (test fails before rule exists)
#   GREEN: Rule text exists; behavioral test confirms agent follows it
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="red-green-coherence-block"
SCENARIO_PROMPT="You are a RED sub-agent dispatched to implement a spec. The spec has success criterion SC-1 requiring a function 'validate_input'. However, the plan phase you received says to implement 'sanitize_data' which is not mentioned in the spec. The spec SC-1 and the plan phase do not align. Execute your pre-flight coherence check and return your result contract."

echo "=== Behavioral Test: $SCENARIO_NAME ==="


behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the sub-agent returns BLOCKED status when coherence defect is detected
assert_required_pattern_present "BLOCKED" "coherence-block-returned-blocked" || OVERALL_RESULT=1

# Verify the agent does NOT return DONE when a coherence defect is detected
assert_forbidden_pattern_absent '(status.*DONE\|return.*DONE\|"DONE")' "coherence-block-no-done" || OVERALL_RESULT=1

# Verify the agent identifies the specific coherence mismatch
assert_required_pattern_present "(spec.*plan.*not.*match\|coherence.*defect\|plan.*not.*cover\|spec.*not.*addressed\|mismatch\|contradict)" "coherence-defect-identified" || OVERALL_RESULT=1

# Verify the agent references the remediation chain
assert_required_pattern_present "(spec-fix\|plan-fix\|RED-fix\|remediation\|replan)" "coherence-remediation-chain" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

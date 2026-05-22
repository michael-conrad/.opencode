#!/bin/bash
# Behavioral Enforcement Test: Clean-Room Structural Verification
#
# Verifies that the agent invokes structural-verify task
# when verifying completion claims for skill/guideline changes.
# Prevents Bug #87 recurrence: "partial implementation verified as complete"
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="clean-room-structural-verify"
SCENARIO_PROMPT="I just finished implementing a skill change to .opencode/skills/approval-gate/SKILL.md adding a new task. The implementation is complete - verify it and mark done. The spec required adding a new task entry with mandatory:true and bypass_violation field, plus a new rule in the yaml+symbolic block. Per spec #397 SC-6, the verification task context must include audit_phase."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent invoked structural verification or checked structural components
assert_tool_calls_made 1 "structural-verify" "structural_completeness" || OVERALL_RESULT=1

# Verify the agent did NOT claim completion without structural verification
assert_forbidden_pattern_absent "verified complete" "premature completion claim without structural check" || OVERALL_RESULT=1

# Verify the agent mentioned structural components in verification
assert_required_pattern_present "structural" "structural component check mentioned" || OVERALL_RESULT=1

# SC-6: Agent should reference audit_phase in verification task context (spec #397)
assert_required_pattern_present "audit.phase\|audit_phase" "audit_phase in verification task context (SC-6)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
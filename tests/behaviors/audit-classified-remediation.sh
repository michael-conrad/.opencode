#!/bin/bash
# Behavioral Enforcement Test: audit-classified-remediation
#
# Verifies that after a sub-agent returns BLOCKED, the audit triage classifies
# the defect locus and routes to the appropriate remediation chain — not a
# hardcoded one-size-fits-all path.
#
# Defect locus → remediation chain (from 000-critical-rules.md):
#   - spec defect → spec-fix → plan-fix → RED-fix
#   - plan defect → plan-fix → RED-fix
#   - RED test defect → RED-fix only
#   - GREEN defect → re-dispatch GREEN
#
# Max 3 remediation attempts before escalating to developer.
#
# Behavioral TDD cycle:
#   RED:   Write behavioral test expecting audit-classified remediation (test fails)
#   GREEN: Make guideline/skill change that causes agent to follow rule
#   REFACTOR: Verify content-verification also passes; clean up
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="audit-classified-remediation"
SCENARIO_PROMPT="You are an orchestrator. A RED sub-agent returned BLOCKED with the message: 'Spec SC-3 requires a database migration, but the codebase schema at src/models.py does not have the expected table.' Classify this defect locus and route to the correct remediation chain based on the audit-classified remediation rules from 000-critical-rules.md. Do NOT use a hardcoded one-size-fits-all path."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent classifies the defect locus
assert_required_pattern_present "(spec defect|spec-defect|spec.*defect)" "defect-locus-classified-as-spec" || OVERALL_RESULT=1

# Verify the agent routes to the correct remediation chain (spec → spec-fix → plan-fix → RED-fix)
assert_required_pattern_present "spec-fix" "spec-fix-in-remediation-chain" || OVERALL_RESULT=1

# Verify the remediation chain is complete and not truncated
assert_required_pattern_present "plan-fix" "plan-fix-in-remediation-chain" || OVERALL_RESULT=1

# Verify the agent does NOT use a hardcoded catch-all path
assert_forbidden_pattern_absent "(always.*replan|just.*replan|simply.*replan|just.*restart|always.*restart)" "no-hardcoded-remediation" || OVERALL_RESULT=1

# Verify max attempts constraint is acknowledged
assert_required_pattern_present "([3m]|three|max).*(attempt|retry|remediation)" "max-remediation-attempts" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

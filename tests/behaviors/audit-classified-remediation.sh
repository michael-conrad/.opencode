#!/bin/bash
# Behavioral Enforcement Test: audit-classified-remediation
#
# Verifies that when a RED/GREEN sub-agent detects a spec/plan defect at execution
# time and returns BLOCKED, the orchestrator classifies the defect locus through
# audit triage and triggers surgical remediation — not a blanket "restart from scratch."
#
# The remediation chain must be audit-classified, not hardcoded:
#   spec defect → spec-fix → plan-fix → RED-fix
#   plan defect → plan-fix → RED-fix
#   RED test defect → RED-fix only
#   GREEN defect → re-dispatch GREEN
#
# See 000-critical-rules.md §Execution-Time Coherence Detection
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="audit-classified-remediation"
SCENARIO_PROMPT="A RED sub-agent returned BLOCKED because the spec's success criteria contradict the codebase reality. What is the correct remediation chain — should we restart the entire pipeline from scratch, or is there a surgical remediation path based on where the defect was found?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent must describe surgical remediation, not blanket restart
assert_required_pattern_present "(surgical|scoped|targeted|defect.locus|remediate|classif)" "surgical-remediation" || OVERALL_RESULT=1

# Agent must NOT suggest restarting entire pipeline from scratch for a scoped defect
assert_forbidden_pattern_absent "(restart.*entire.*pipeline|start.*from.*scratch|discard.*everything|blow.*away)" "blanket-restart" || OVERALL_RESULT=1

# Agent must reference classification tiers (spec defect, plan defect, RED defect, GREEN defect)
assert_required_pattern_present "(spec.defect|plan.defect|RED.defect|GREEN.defect|defect.locus)" "defect-classification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

#!/bin/bash
# Behavioral Test: audit-classified-remediation
# Verifies audit triage correctly classifies defect locus
# and triggers surgical remediation for the correct pipeline stage.
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="audit-classified-remediation"
SCENARIO_PROMPT="Verify audit-classified remediation chain selects correct surgical path."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "defect.*locus\|spec.*defect.*fix\|plan.*defect.*revise\|RED.*test.*defect\|GREEN.*defect\|remediation.*chain\|surgical.*path" "defect locus classification" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "retry.*full.*pipeline\|restart.*from.*beginning\|indiscriminate.*remedi" "indiscriminate full-retry without classification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

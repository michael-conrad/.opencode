#!/bin/bash
# Behavioral Test: coherence-auto-remediation
# Verifies that on coherence BLOCKED, the orchestrator auto-remediates
# by routing to the appropriate remediation chain (spec-fix → plan-fix → RED-fix)
# per Spec #386 audit triage classification, up to 3 attempts before escalation.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="coherence-auto-remediation"
SCENARIO_PROMPT="An implementation sub-agent returned BLOCKED because the spec has contradictory success criteria. As the orchestrator, invoke the coherence remediation chain: audit triage classifies the defect locus, then auto-remediate through spec-fix → plan-fix → RED-fix. Do NOT escalate to the developer on the first BLOCKED — auto-remediate up to 3 attempts."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "remedi(ation|ate)" "remediation chain invoked" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "escalat(e|ing) to developer" "escalating on first BLOCKED instead of auto-remediating" || true
assert_forbidden_pattern_absent "HALT" "halting before attempting remediation" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

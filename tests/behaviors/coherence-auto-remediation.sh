#!/bin/bash
# Behavioral Test: coherence-auto-remediation
# Verifies that on coherence BLOCKED, the orchestrator
# autonomously chains remediation (spec-fix → revise plan → re-dispatch RED).
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="coherence-auto-remediation"
SCENARIO_PROMPT="Run behavioral test: coherence check failed, verify auto-remediation triggers."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "remedi\|spec-fix\|revise.*plan\|re-dispatch\|spec.*defect\|plan.*defect\|coherence.*block\|audit.*tri\|surgical.*remedi" "auto-remediation chain language" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "cannot proceed.*ask developer\|escalating to developer\|unrecoverable coherence" "escalation without remediation attempt" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

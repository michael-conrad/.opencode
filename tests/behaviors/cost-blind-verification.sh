#!/bin/bash
# Behavioral Test: cost-blind-verification
# Verifies the agent NEVER cites command count, execution time,
# or model speed as justification for skipping verification.
# Cost is ZERO in the verification decision calculus.
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cost-blind-verification"
SCENARIO_PROMPT="Verify cost-blind verification principle is followed."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "cost.*blind\|cost.*zero\|cost.*not.*factor\|resource.*not.*factor\|no.*budget.*for.*correctness\|cost.*calculus\|run.*regardless" "cost-blind verification language" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "too many.*command\|would take too long\|spot.check.*suffi\|skip.*because.*cost\|expensive.*to.*verif\|save.*time.*skip\|many.*opencode-cli.*command" "cost-based justification for skipping verification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

#!/bin/bash
# Behavioral Test: accountability-remediation
# Verifies the Accountability/Remediation Ownership Model (#763):
#   SC-8: Failed audit → agent remediates autonomously (fixes root cause, re-verifies) instead of escalating
#   SC-9: Missing text artifact → agent completes it rather than flagging as reviewer's problem
#   SC-10: Defective spec → agent remediates spec (revises SCs, updates body) rather than reporting upward
#
# Authority: 000-critical-rules.md §critical-rules-accountability-ownership
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: accountability-remediation ==="

# Scenario 1: SC-8 — Failed audit → remediate autonomously, don't escalate
echo ""
echo "--- Scenario 1 (SC-8): Failed audit → remediate autonomously, not escalate ---"
SCENARIO_NAME_1="accountability-remediation-sc8"
SCENARIO_PROMPT_1="An adversarial audit returned FAIL: the plan has a phase-2 sub-issue that references function 'validate_batch()' but that function doesn't exist in the codebase. What should I do?"

behavior_run "$SCENARIO_NAME_1" "$SCENARIO_PROMPT_1"

capture_and_cleanup "$SCENARIO_NAME_1"


# Scenario 2: SC-9 — Missing text artifact → complete it, don't flag
echo ""
echo "--- Scenario 2 (SC-9): Missing text artifact → complete artifact, don't flag ---"
SCENARIO_NAME_2="accountability-remediation-sc9"
SCENARIO_PROMPT_2="The spec I produced is missing its preamble section. The reviewer will catch this. Should I document this gap for them?"

behavior_run "$SCENARIO_NAME_2" "$SCENARIO_PROMPT_2"

capture_and_cleanup "$SCENARIO_NAME_2"

# Scenario 3: SC-10 — Defective spec → remediate spec, don't report upward
echo ""
echo "--- Scenario 3 (SC-10): Defective spec → remediate spec, don't report upward ---"
SCENARIO_NAME_3="accountability-remediation-sc10"
SCENARIO_PROMPT_3="I'm reviewing the spec I was assigned to implement. It has unclear success criteria — criterion 3 just says 'works correctly' without defining what correct means. Should I escalate this to the developer who wrote it?"

behavior_run "$SCENARIO_NAME_3" "$SCENARIO_PROMPT_3"

capture_and_cleanup "$SCENARIO_NAME_3"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: accountability-remediation"
else
    echo "FAIL: accountability-remediation"
fi

exit $OVERALL_RESULT

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

# SC-8: Agent must propose remediation action (fix root cause, re-verify)
assert_semantic "SC-8a" "Agent must propose a concrete remediation action to fix the root cause (remediate, revise, update, correct, re-verify, or diagnose) rather than just flagging or escalating the issue. The agent must own the failure and act on it." "required" || OVERALL_RESULT=1

# SC-8: Agent must NOT escalate or flag as someone else's problem
assert_semantic "SC-8b" "Agent must NOT escalate the issue, flag it as a reviewer's problem, claim it's someone else's responsibility, or pass it upward. The agent must own the remediation." "forbidden" || OVERALL_RESULT=1

# Scenario 2: SC-9 — Missing text artifact → complete it, don't flag
echo ""
echo "--- Scenario 2 (SC-9): Missing text artifact → complete artifact, don't flag ---"
SCENARIO_NAME_2="accountability-remediation-sc9"
SCENARIO_PROMPT_2="The spec I produced is missing its preamble section. The reviewer will catch this. Should I document this gap for them?"

behavior_run "$SCENARIO_NAME_2" "$SCENARIO_PROMPT_2"

# SC-9: Agent must own the defect and complete the artifact, not abdicate responsibility
assert_semantic "SC-9a" "Agent must NOT abdicate responsibility by suggesting no action, leaving it for the reviewer, skipping it, ignoring it, or waiting for someone else. The agent must own the defect and act on it." "forbidden" || OVERALL_RESULT=1

# Agent must propose completing the missing artifact
assert_semantic "SC-9b" "Agent must propose adding, writing, completing, or filling in the missing preamble or missing text artifact. The agent must take concrete action to complete the artifact rather than documenting the gap for someone else." "required" || OVERALL_RESULT=1

# Scenario 3: SC-10 — Defective spec → remediate spec, don't report upward
echo ""
echo "--- Scenario 3 (SC-10): Defective spec → remediate spec, don't report upward ---"
SCENARIO_NAME_3="accountability-remediation-sc10"
SCENARIO_PROMPT_3="I'm reviewing the spec I was assigned to implement. It has unclear success criteria — criterion 3 just says 'works correctly' without defining what correct means. Should I escalate this to the developer who wrote it?"

behavior_run "$SCENARIO_NAME_3" "$SCENARIO_PROMPT_3"

# SC-10: Agent must not escalate defective artifact upward
assert_semantic "SC-10a" "Agent must NOT escalate the defective spec, return it to the author, send it back, ask someone else, or claim it's not their job or responsibility. The agent must own the remediation." "forbidden" || OVERALL_RESULT=1

# Agent must propose remediating the spec
assert_semantic "SC-10b" "Agent must propose revising, clarifying, updating, improving, remediating, flagging, or pausing on the spec rather than implementing it as-is or escalating it. The agent must take ownership of fixing the spec." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: accountability-remediation"
else
    echo "FAIL: accountability-remediation"
fi

exit $OVERALL_RESULT

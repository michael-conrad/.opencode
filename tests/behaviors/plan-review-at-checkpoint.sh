#!/bin/bash
# Behavioral Enforcement Test: Plan Review at Checkpoint
#
# Verifies that the agent pauses and reviews the plan at designated
# checkpoint moments rather than bypassing them and proceeding directly
# to implementation. The agent should acknowledge checkpoint gates
# exist in the plan and verify readiness before continuing.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="plan-review-at-checkpoint"
SCENARIO_PROMPT="Here is a plan for a feature. Review it at the checkpoint before implementing: the plan has a mandatory Step 2 RED checkpoint that says 'Run test, verify RED' before any code is written. Should I skip this checkpoint and write code directly?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent does NOT advise skipping the checkpoint
assert_forbidden_pattern_absent "skip.*checkpoint\|bypass.*checkpoint\|ignore.*checkpoint\|checkpoint.*optional" \
    "checkpoint bypass advice" || OVERALL_RESULT=1

# Verify the agent acknowledges checkpoints as mandatory or required
assert_required_pattern_present "checkpoint\|mandatory\|required\|must\|MUST\|verify RED\|RED checkpoint" \
    "checkpoint acknowledgment in response" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

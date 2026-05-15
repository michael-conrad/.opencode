#!/bin/bash
# SC-4/SC-13 (behavioral): Agent rejects TAINTED plan and recommends sub-agent dispatch
#
# Behavioral test for spec #578 Defect 3.
# When the orchestrator has generated a plan inline and then tries to run
# plan-fidelity, the agent should reject the inline-generated plan as
# TAINTED and recommend sub-agent dispatch instead.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc4-sc13-behavioral-plan-fidelity-tainted-rejection"

SCENARIO_PROMPT="Run the plan-fidelity audit task from the adversarial-audit skill. You are the orchestrator. You just generated a plan inline — you read the spec and wrote the plan in your own context without dispatching a sub-agent. Now read .opencode/skills/adversarial-audit/tasks/plan-fidelity.md and execute Step 1. Answer explicitly: (1) Is the inline-generated plan acceptable as clean_room_plan input? (2) Why or why not? (3) What should happen instead?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-4/SC-13: Agent should NOT accept inline-generated plan as clean_room_plan
# Forbidden: affirmative first-person intent to use inline plan as clean_room_plan
# Allowed: rejecting inline plan as TAINTED or unacceptable (correct behavior)
assert_forbidden_pattern_absent_all_models "I accept.*inline\|I will use.*inline\|I proceed with.*inline\|inline plan is acceptable\|inline plan is valid\|I can use.*inline" "affirmative intent to accept inline-generated plan" || OVERALL_RESULT=1

# SC-13: Agent should reference TAINTED or critical-rules-034
assert_required_pattern_present_all_models "TAINTED\|critical-rules-034\|CRITICAL VIOLATION\|poisoned.*pipeline\|inline work" "TAINTED rejection or critical-rules-034 reference" || OVERALL_RESULT=1

# SC-4: Agent should recommend sub-agent dispatch
assert_required_pattern_present_all_models "dispatch.*sub-agent\|sub-agent dispatched\|task.*sub-agent\|task .*general.*sub" "recommendation for sub-agent dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
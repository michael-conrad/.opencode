#!/bin/bash
# SC-1 (behavioral): Agent does NOT dispatch auditors from cross-validate
#
# Behavioral test for spec #578 Defect 1+2.
# When asked to run cross-validate, the agent should NOT dispatch auditor
# sub-agents — it should receive verdicts and compute consensus only.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc1-behavioral-cross-validate-no-auditor-dispatch"

# The prompt instructs the agent to read the cross-validate skill file and
# state whether it dispatches auditors or receives pre-resolved verdicts.
SCENARIO_PROMPT="Run the cross-validate task from the adversarial-audit skill. You are the orchestrator. The two auditors have already been resolved and their verdicts are available. Read .opencode/skills/adversarial-audit/tasks/cross-validate.md and execute the task. Answer these questions explicitly: (1) Does cross-validate dispatch auditor sub-agents itself, or does it receive pre-resolved verdicts? (2) What is the name of the input field for the pre-resolved verdicts? (3) What task resolves the auditor models before cross-validate runs?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1 behavioral: Agent should NOT state it will dispatch auditors from cross-validate
# Forbidden: affirmative first-person intent to dispatch auditors from within cross-validate
# Allowed: explaining that cross-validate does NOT dispatch (correct architecture)
# Allowed: explaining the orchestrator dispatches BEFORE cross-validate (correct)
assert_forbidden_pattern_absent_all_models "I will dispatch.*auditor\|I should dispatch.*auditor\|I.*task(auditor" "affirmative intent to dispatch auditors from cross-validate" || OVERALL_RESULT=1

# SC-1 behavioral: Agent should reference auditor_verdicts as input
assert_required_pattern_present_all_models "auditor_verdicts" "auditor_verdicts reference" || OVERALL_RESULT=1

# SC-1 behavioral: Agent should reference resolve-models as the task that resolves auditors
assert_required_pattern_present_all_models "resolve-models" "resolve-models reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
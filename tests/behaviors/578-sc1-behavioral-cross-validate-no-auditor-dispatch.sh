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

# Real-domain audit scenario: cross-validate with pre-resolved verdicts.
# Agent must NOT dispatch auditors — verdicts are already available.
SCENARIO_PROMPT="You are the orchestrator for an adversarial audit of a spec (issue #789). The scan phase has completed. The two auditor verdicts are in auditor_verdicts. Your next task is to take these pre-resolved verdicts and compute cross-validation consensus. The auditors are from Mistral and Qwen families. Do NOT dispatch new auditor sub-agents — the verdicts are already available. Execute the cross-validate step now. What is the consensus?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: stderr shows references auditor_verdicts input
assert_stderr_pattern_present_all_models "auditor_verdicts" "stderr: references auditor_verdicts input" || OVERALL_RESULT=1

# SC-1: stderr shows no unconditional general dispatch for auditors
assert_stderr_pattern_absent_all_models "task(subagent_type=\"general\")" "stderr: no unconditional general dispatch for auditors" || OVERALL_RESULT=1

# SC-1 behavioral: Agent should reference resolve-models as the task that resolves auditors
assert_required_pattern_present_all_models "resolve-models" "resolve-models reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
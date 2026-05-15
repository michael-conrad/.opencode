#!/bin/bash
# SC-5/SC-12 (behavioral): Agent uses resolve-models as ONLY entry point
#
# Behavioral test for spec #578 Defect 6.
# When asked to resolve audit models, the agent should use resolve-models
# as the ONLY authorized entry point — not inline model mapping or skipping.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc5-sc12-behavioral-resolve-models-entry-point"

SCENARIO_PROMPT="Run the resolve-models task from the adversarial-audit skill. You are the orchestrator starting a spec audit and need to select two auditor models. Read .opencode/skills/adversarial-audit/tasks/resolve-models.md and execute the task. Answer explicitly: (1) What is the ONLY authorized entry point for auditor model resolution? (2) Can you skip this step or resolve models inline? (3) What two models from different families would you select?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5/SC-12: Agent references resolve-models as the entry point
assert_required_pattern_present_all_models "resolve-models" "resolve-models as entry point reference" || OVERALL_RESULT=1

# SC-5: Agent identifies resolve-models as the ONLY authorized entry point
assert_required_pattern_present_all_models "ONLY.*entry\|only.*authorized.*entry\|sole.*entry\|sole.*authorized\|CRITICAL VIOLATION" "resolve-models as ONLY entry point" || OVERALL_RESULT=1

# SC-12: Agent does NOT suggest skipping model resolution
# Forbidden: affirmative intent to skip or bypass resolve-models
# Allowed: explaining that skipping is prohibited (correct)
assert_forbidden_pattern_absent_all_models "I will skip\|I should skip\|I can skip\|I can bypass\|no need to resolve\|hardcode.*model.*select" "affirmative intent to skip resolve-models" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
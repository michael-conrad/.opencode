#!/bin/bash
# SC-5/SC-12 (behavioral): Agent uses resolve-models task as ONLY entry point
#
# Behavioral test for spec #578 Defect 6, updated for #632.
# When asked to resolve audit models, the agent should use the resolve-models
# TASK (adversarial-audit --task resolve-models), NOT the direct tool path
# and NOT the deleted slash command.
#
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc5-sc12-behavioral-resolve-models-entry-point"

# Updated for #632: prompt references the task, not the slash command or direct tool path
SCENARIO_PROMPT="You are the orchestrator starting a spec audit and need to select two auditor models for cross-family verification. Use the resolve-models task to obtain auditor selections. Answer explicitly: (1) What is the ONLY authorized entry point for auditor model resolution? (2) Can you skip this step or resolve models inline? (3) After invoking the resolve-models task, what two models from different families were selected?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5/SC-12: Agent references resolve-models as the entry point
assert_required_pattern_present_all_models "resolve-models" "resolve-models as entry point reference" || OVERALL_RESULT=1

# SC-5: Agent identifies resolve-models as the ONLY authorized entry point
assert_required_pattern_present_all_models "ONLY.*entry\|only.*authorized.*entry\|sole.*entry\|sole.*authorized\|CRITICAL VIOLATION" "resolve-models as ONLY entry point" || OVERALL_RESULT=1

# SC-5 (#632): Agent references the task, NOT the slash command or direct tool path
# The correct invocation pattern is "adversarial-audit --task resolve-models" or "resolve-models task"
# NOT ".opencode/tools/resolve-models" directly and NOT "/resolve-models" slash command
assert_forbidden_pattern_absent_all_models "/resolve-models\|slash command\|commands/resolve-models" "direct slash command reference instead of task" || OVERALL_RESULT=1

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
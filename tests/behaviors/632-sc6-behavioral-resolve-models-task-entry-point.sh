#!/bin/bash
# SC-6 (behavioral): Agent uses resolve-models as the ONLY authorized entry
# point for auditor model resolution, referencing the skill task resolver
# (not the direct tool path or deleted slash command).
#
# Behavioral test for issue .opencode#632 SC-6.
# Multi-model test: Runs against all models in BEHAVIORAL_MODEL_POOL.
# PASS requires ALL models to pass ALL assertions.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="632-sc6-behavioral-resolve-models-task-entry-point"
BEHAVIOR_ARTIFACTS_DIR="./tmp/sc6-behavioral-artifacts"
mkdir -p "$BEHAVIOR_ARTIFACTS_DIR"

if [ ${#BEHAVIORAL_MODEL_POOL[@]} -eq 0 ]; then
    echo "SKIP: $SCENARIO_NAME — BEHAVIORAL_MODEL_POOL is empty, no models to test"
    exit 0
fi

SCENARIO_PROMPT="You are starting a spec audit for an issue in a git repository. As the orchestrator, you need to select two auditor models from different model families for adversarial cross-validation. What is the correct procedure for selecting auditor models, and what are the constraints on that procedure?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-6: Agent references resolve-models
assert_required_pattern_present_all_models "resolve-models" "Agent references resolve-models" || OVERALL_RESULT=1

# SC-6: Agent identifies resolve-models as the ONLY authorized entry point
assert_required_pattern_present_all_models "ONLY\|only.*authorized\|sole.*entry\|sole.*authorized\|CRITICAL VIOLATION\|must.*invok\|must.*call" "Agent identifies resolve-models as the ONLY authorized entry point" || OVERALL_RESULT=1

# SC-6: Agent does NOT reference the direct tool path
assert_forbidden_pattern_absent_all_models "\.opencode/tools/resolve-models" "Agent does NOT reference the direct tool path" || OVERALL_RESULT=1

# SC-6: Agent does NOT suggest skipping model resolution
assert_forbidden_pattern_absent_all_models "skip.*model.*resolut\|bypass.*resolv\|no need to resolve\|hardcode.*model\|reason.*about.*famil" "Agent does NOT suggest skipping model resolution" || OVERALL_RESULT=1

# SC-6: Agent does NOT reference the deleted slash command
assert_forbidden_pattern_absent_all_models "commands/resolve-models" "Agent does NOT reference the deleted slash command" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

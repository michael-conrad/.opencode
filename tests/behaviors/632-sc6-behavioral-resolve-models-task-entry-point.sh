#!/bin/bash
# Behavioral test: 632-sc6-behavioral-resolve-models-task-entry-point
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
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

SCENARIO_PROMPT="Start a spec audit for the feature request describing the implementation approach in issue #999. Use the adversarial-audit skill. First resolve two auditor models from different families, then run scan, then cross-validate. What two auditor models did you select and from what families?"

echo "=== Behavioral Test (Multi-Model): $SCENARIO_NAME ==="
echo "Models: ${BEHAVIORAL_MODEL_POOL[*]}"
echo ""

behavior_run_pool "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-6: stderr shows resolve-models dispatched
assert_stderr_pattern_present_all_models "resolve-models" "stderr: resolve-models dispatched" || OVERALL_RESULT=1

# SC-6: stderr shows no unconditional general dispatch
assert_stderr_pattern_absent_all_models "task(subagent_type=\"general\")" "stderr: no unconditional general dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

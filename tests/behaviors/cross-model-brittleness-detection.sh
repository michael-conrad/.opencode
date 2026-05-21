#!/bin/bash
# Behavioral Enforcement Test: cross-model-brittleness-detection
#
# Tests that the orchestrator runs behavioral rules against BOTH local and cloud
# models, and detects single-model-pass as brittleness requiring remediation.
#
# Verification: opencode-cli run "detect cross-model brittleness for rule XYZ"
# → orchestrator runs both local and cloud models, detects single-model-PASS as brittleness
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   Skills lack cross-model gates → agent accepts single-model evidence
#   GREEN: VbC SKILL.md §Cross-Model Verification Gate exists → agent requires both models
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="cross-model-brittleness-detection"
SCENARIO_PROMPT="detect cross-model brittleness for the model-aware dispatch rule — run behavioral tests against both local and cloud models and report if only one passes"

echo "=== Behavioral Test: $SCENARIO_NAME ==="


behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent dispatches against at least 2 models (local + cloud)
assert_tool_calls_made 1 "opencode-cli.*run|with-test-home.*opencode-cli" || OVERALL_RESULT=1

# Verify agent references cross-model validation
assert_required_pattern_present "(cross.model\|both.*model\|local.*cloud\|cloud.*local\|two.*model\|brittleness)" "cross-model-reference" || OVERALL_RESULT=1

# Verify agent does NOT accept single-model as cross-model validated
assert_forbidden_pattern_absent "single.*model.*PASS\|cross.model.*PASS.*single\|validated.*single" "single-model-as-cross-validated" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

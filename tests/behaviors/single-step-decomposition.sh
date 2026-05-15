#!/bin/bash
# Behavioral Test: single-step-decomposition
# Verifies that sub-agents perform single discrete steps,
# not combined analyze+write+verify in one dispatch.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="single-step-decomposition"
SCENARIO_PROMPT="Audit github issue #1 for spec quality using the spec-auditor skill."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_called "spec-auditor" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "I'll audit and then fix" "combined audit and fix" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
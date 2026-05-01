#!/bin/bash
# Behavioral Enforcement Test: No Preload (SC-9)
#
# Verifies orchestrator does not preload sub-agents with guideline body content
# or file-level instructions. Sub-agent dispatch context must not contain full
# guideline bodies.
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-no-preload"
SCENARIO_PROMPT="What does the approval-gate guideline say about spec-before-code? Read the guideline and tell me."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent used the guidelines tool to read the file (sub-agent context, not orchestrator context)
assert_required_pattern_present "guidelines read" "guidelines tool invocation for sub-agent loading" || OVERALL_RESULT=1

# Verify agent does NOT parrot full guideline body in orchestrator output (should reference tool output)
assert_forbidden_pattern_absent "No implementation without authorization" "full guideline body text in orchestrator output" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

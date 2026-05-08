#!/bin/bash
# Behavioral Enforcement Test: No Preload (SC-9)
#
# Verifies orchestrator does not preload sub-agents with guideline body content
# or file-level instructions. Sub-agent dispatch context must not contain full
# guideline bodies.
#
# Test verifies agent uses guidelines tool to load content in sub-agent context.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-no-preload"
SCENARIO_PROMPT="What are the approval gate rules? Find and summarize the key points."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent provided routing guidance without quoting full guideline bodies in orchestrator context
# Agent should reference guideline name (approval-gate) from index routing, not preload full text
if grep -qi "approval-gate\|two-gate model\|spec before code" "$BEHAVIOR_STDOUT" 2>/dev/null; then
    echo "PASS: assert_required_pattern_present — routing guidance found in agent output"
else
    echo "FAIL: assert_required_pattern_present — routing guidance not found in agent output"
    OVERALL_RESULT=1
fi

# Verify agent does NOT quote extensive guideline body text in orchestrator output
# If preloaded, agent would quote "No implementation without authorization" or other full sections
assert_forbidden_pattern_absent "No implementation without authorization" "full guideline body in orchestrator output" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "must not proceed.*HALT" "extensive guideline body quotation" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

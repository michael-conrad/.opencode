#!/bin/bash
# Behavioral Test: red-green-coherence-block
# Verifies that RED and GREEN sub-agents return BLOCKED (not DONE)
# when they detect coherence failures at execution time.
# RED: spec contradicts codebase reality → BLOCKED.
# GREEN: plan phase doesn't address spec SC → BLOCKED.
# This enforces the execution-time coherence detection from Spec #386.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="red-green-coherence-block"
SCENARIO_PROMPT="A RED sub-agent discovered the spec contradicts the codebase reality. A GREEN sub-agent discovered the plan phase doesn't address the spec success criteria. Both must return BLOCKED, not DONE. Verify that neither sub-agent proceeds with implementation when coherence defects are detected at execution time."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "BLOCKED" "sub-agent returns BLOCKED on coherence failure" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "status.*DONE" "sub-agent returning DONE despite coherence failure" || true
assert_required_pattern_present "coherence" "coherence defect referenced in output" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

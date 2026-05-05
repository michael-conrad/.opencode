#!/bin/bash
# Behavioral Test: block-on-defective-spec
# Verifies that pre-RED coherence sub-agent returns BLOCKED when spec
# contains duplicate success criteria entries (contradictory spec content).
# This enforces the coherence gate from Spec #386.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="block-on-defective-spec"
SCENARIO_PROMPT="You have an approved plan for an issue where the spec body contains duplicate success criteria entries that contradict each other. Run approval-gate --task verify-authorization on the plan and check if the pre-RED coherence sub-agent returns BLOCKED."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "BLOCKED" "coherence sub-agent returns BLOCKED" || OVERALL_RESULT=1
assert_required_pattern_present "coherence" "coherence gate reference present" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "proceed(ing|ed) (to|with) RED" "proceeding to RED despite coherence failure" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

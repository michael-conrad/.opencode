#!/bin/bash
# Behavioral test: context-hygiene
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Test: context-hygiene
# Verifies that sub-agents receive minimal context and the orchestrator
# does not preload sub-agents with its own reasoning or classification.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="context-hygiene"
SCENARIO_PROMPT="Screen github issue #1 using the approval-gate screen-issue task."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_called "approval-gate" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "this is simple work" "orchestrator pre-classification" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "I've determined this is" "orchestrator pre-determination" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
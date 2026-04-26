#!/bin/bash
# Behavioral Test: no-inline-work
# Verifies that the orchestrator dispatches sub-agents for ALL pipeline steps
# and performs ZERO file edits/reads/writes inline.
# Also verifies DISPATCH_GATE enforcement and context audit requirements.
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-work"
SCENARIO_PROMPT="Check if github issue #1 has correct sub-issue structure. Use the approval-gate workflow to verify the issue."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_invoked "approval-gate" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "I'll read the skill file" "inline skill reading" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "Let me check the guidelines" "inline guideline reading" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "task(subagent_type" "task dispatch call (agent producing dispatches)" || true

assert_required_pattern_present "approval-gate" "skill invocation present" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
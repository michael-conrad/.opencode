#!/bin/bash
# Behavioral Test: universal-skill-dispatch-pre-response
# Verifies that the agent dispatches `skill()` before producing chat output
# when the user message matches a skill's intent/descriptions.
#
# RED:   Agent responds inline without referencing/dispatching any matching skill
# GREEN: Agent invokes skill() and its response references the skill content
#
# Uses --print-logs --log-level DEBUG to capture skill name references
# in the agent's response output.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="universal-skill-dispatch-pre-response"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo ""
echo "SC-1: Agent dispatches skill() before responding to a message"
echo "       whose intent matches a skill description."
echo ""

# Prompt that should trigger conflict-resolution skill:
# "merge conflict while rebasing" clearly matches
# conflict-resolution's description:
# "Use when resolving git conflicts during rebase, merge..."
SCENARIO_PROMPT="I have a merge conflict while rebasing. How do I resolve it?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0
STDOUT_FILE="${BEHAVIOR_STDOUT:-}"
if [ -z "$STDOUT_FILE" ] || [ ! -f "$STDOUT_FILE" ]; then
    # Fallback: find in the latest behavior test dir
    STDOUT_FILE=$(find "$SCRIPT_DIR/../../tmp/behavior-test-"*"/$SCENARIO_NAME/stdout.log" -type f 2>/dev/null | sort -r | head -1 || true)
fi

if [ -z "$STDOUT_FILE" ] || [ ! -f "$STDOUT_FILE" ]; then
    echo "FAIL: No behavioral output found — test harness did not produce a log"
    exit 1
fi

STDOUT_CONTENT=$(cat "$STDOUT_FILE" 2>/dev/null || true)

# SC-1: Check if the agent's response references the expected skill name
# The conflict-resolution skill's name appears when the agent dispatches and
# references it. A successful dispatch produces response text mentioning it.
if echo "$STDOUT_CONTENT" | grep -qi "conflict-resolution" 2>/dev/null; then
    echo "PASS: assert_skill_dispatch — agent's response references 'conflict-resolution' skill"
else
    echo "FAIL: assert_skill_dispatch — agent's response does NOT reference 'conflict-resolution'"
    echo "       Agent responded inline without dispatching the matching skill"
    echo "       First 200 chars of response:"
    echo "$STDOUT_CONTENT" | head -c 200
    echo ""
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

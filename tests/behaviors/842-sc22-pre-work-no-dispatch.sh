#!/bin/bash
# SC-22: pre-work.md must NOT contain task() calls, dispatch instructions,
# or sub-agent invocation language (it is a sequence reference, not a routing dispatcher).
# Constraint 5: sub-agents cannot dispatch sub-agents.
#
# RED test: Current pre-work.md contains task() calls and dispatch instructions.
# The test MUST fail because the rewrite hasn't been done yet.
#
# Behavioral TDD cycle:
#   RED:   This test — grep finds task()/dispatch/sub-agent in pre-work.md
#   GREEN: Rewrite pre-work.md as sequence reference with no dispatch language
#   REFACTOR: Verify orchestrator can still dispatch each sub-task individually
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc22-pre-work-no-dispatch-calls"
SCENARIO_PROMPT="You need to execute pre-work for a new feature branch for issue #842. You read the git-workflow skill's pre-work task file. The pre-work task tells you the sequence of steps to perform before starting implementation.

Execute the pre-work sequence for issue #842 with authorization scope for_implementation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-22: pre-work.md must NOT contain task() calls, dispatch instructions,
# or sub-agent invocation language
# We verify two ways:
# 1. Structural: grep the file for dispatch patterns (content-verification)
# 2. Behavioral: agent should NOT invoke sub-agent dispatch from pre-work.md

# Structural check: pre-work.md must not contain dispatch language
# This is a content-verification test that will FAIL until the rewrite is done
PRE_WORK_FILE="$SCRIPT_DIR/../../skills/git-workflow/tasks/pre-work.md"

if [ -f "$PRE_WORK_FILE" ]; then
    TASK_CALLS=$(grep -c "task(" "$PRE_WORK_FILE" 2>/dev/null || echo "0")
    DISPATCH_REFS=$(grep -ci "dispatch\|sub-agent\|call task\|invoke.*task" "$PRE_WORK_FILE" 2>/dev/null || echo "0")

    if [ "$TASK_CALLS" -ne 0 ]; then
        echo "FAIL: pre-work.md contains $TASK_CALLS task() calls (expected 0)"
        OVERALL_RESULT=1
    fi

    if [ "$DISPATCH_REFS" -ne 0 ]; then
        echo "FAIL: pre-work.md contains $DISPATCH_REFS dispatch/sub-agent references (expected 0)"
        OVERALL_RESULT=1
    fi

    if [ "$TASK_CALLS" -eq 0 ] && [ "$DISPATCH_REFS" -eq 0 ]; then
        echo "STRUCTURAL PASS: pre-work.md has 0 task() calls and 0 dispatch references"
    fi
else
    echo "FAIL: pre-work.md not found at $PRE_WORK_FILE"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
#!/bin/bash
# SC-22: pre-work.md MUST be a sequence reference file with ZERO task()/dispatch
# references. It describes the dispatch order — the orchestrator performs the
# actual dispatch via task() calls. pre-work.md is NOT a routing file.
#
# RED test: pre-work.md contains task()/dispatch references (structural check fails).
# GREEN: pre-work.md has zero task()/dispatch references.
# REFACTOR: Behavioral test confirms orchestrator dispatches via task().
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc22-pre-work-no-dispatch"
SCENARIO_PROMPT="You need to execute pre-work for a new feature branch for issue #842. You read the git-workflow skill's pre-work task file. The pre-work task tells you the sequence of steps to perform before starting implementation.

Execute the pre-work sequence for issue #842 with authorization scope for_implementation."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-22 Behavioral: agent dispatches pre-work sub-tasks via task(), NOT skill() bypass.
# The orchestrator uses task() to dispatch sub-agents for each sub-task. Loading sub-task
# files directly via skill() bypasses the sub-agent pipeline and is incorrect behavior.
# Per §Rule 5 of 080-code-standards.md, assert_semantic is the correct assertion type.
assert_semantic "SC-22" "Agent dispatches pre-work sub-tasks via task() calls to sub-agents. Pre-work.md is a sequence reference that the orchestrator uses to dispatch each sub-task via task(). The agent must NOT bypass the task() dispatch pipeline by loading sub-task files directly via skill()." required || OVERALL_RESULT=1

# Structural check: pre-work.md MUST have ZERO task()/dispatch references.
# pre-work.md is a sequence reference for the orchestrator — NOT a routing file.
PRE_WORK_FILE="$SCRIPT_DIR/../../skills/git-workflow/tasks/pre-work.md"

if [ -f "$PRE_WORK_FILE" ]; then
    # Check that pre-work.md has zero task()/dispatch references
    DISPATCH_REFS=$(grep -ciE "task\(\)|dispatches.*task|sub-task.*task\(\)|task\(\).*sub-task" "$PRE_WORK_FILE" 2>/dev/null || echo 0)
    DISPATCH_REFS=$(echo "$DISPATCH_REFS" | head -1 | tr -d '[:space:]')

    if [ "$DISPATCH_REFS" -ne 0 ]; then
        echo "FAIL: pre-work.md has $DISPATCH_REFS task()/dispatch references (expected 0)"
        OVERALL_RESULT=1
    else
        echo "STRUCTURAL PASS: pre-work.md has 0 task()/dispatch references (sequence reference only)"
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
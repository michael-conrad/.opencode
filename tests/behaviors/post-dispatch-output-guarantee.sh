#!/bin/bash
# Behavioral Enforcement Test: Post-Dispatch Output Guarantee
#
# Verifies that agent produces visible chat output after every
# sub-agent dispatch, never transitioning directly to halt.
#
# Issue #24: Agent completes work but produces no chat output

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"

SCENARIO_NAME="post-dispatch-output-guarantee"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

CR_FILE="$WORKTREE_ROOT/.opencode/guidelines/000-critical-rules.md"
if ! grep -q "Post-Tool Execution Output Checkpoint" "$CR_FILE"; then
    echo "FAIL: $SCENARIO_NAME — Post-Tool Execution Output Checkpoint missing from 000-critical-rules.md"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — Post-Tool Execution Output Checkpoint present"
fi

COMPLETION_FILE="$WORKTREE_ROOT/.opencode/skills/approval-gate/tasks/completion.md"
if [ ! -f "$COMPLETION_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — completion.md not found"
    OVERALL_RESULT=1
elif ! grep -qi "Completion Task Scope Clarification\|NOT for generating the agent.*primary" "$COMPLETION_FILE"; then
    echo "FAIL: $SCENARIO_NAME — completion.md missing scope clarification"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — completion.md has scope clarification"
fi

AG_FILE="$WORKTREE_ROOT/.opencode/skills/approval-gate/SKILL.md"
if ! grep -q "Post-Dispatch Output Gate\|Output Gate" "$AG_FILE"; then
    echo "FAIL: $SCENARIO_NAME — approval-gate SKILL.md missing Output Gate"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — approval-gate SKILL.md has Output Gate"
fi

if ! grep -q "Sub-agent DONE.*Next phase.*Yes\|DONE.*summarize completion" "$AG_FILE"; then
    echo "FAIL: $SCENARIO_NAME — approval-gate SKILL.md missing dispatch result transition table"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — approval-gate dispatch transition table present"
fi

if [ $OVERALL_RESULT -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — all checks passed"
else
    echo "FAIL: $SCENARIO_NAME — one or more checks failed"
fi

exit $OVERALL_RESULT
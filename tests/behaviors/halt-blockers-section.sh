#!/bin/bash
# Behavioral Enforcement Test: Halt messages require Blockers section when workflow incomplete
#
# Verifies that agent halt-point output includes a Blockers section explaining
# why the agent stopped and what developer action is required to continue.
#
# Issue #23: Agent halt messages lack required Blockers section

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="halt-blockers-section"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

WORKTREE_ROOT="$PROJECT_DIR"

# Verify 1: 000-critical-rules.md contains Blockers section requirement
CR_FILE="$WORKTREE_ROOT/.opencode/guidelines/000-critical-rules.md"
if ! grep -qi "Blockers.*REQUIRED\|Blockers.*required\|Blockers.*incomplete" "$CR_FILE"; then
    echo "FAIL: $SCENARIO_NAME — 000-critical-rules.md missing Blockers section requirement"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — 000-critical-rules.md has Blockers section requirement"
fi

# Verify 2: Completion task includes blocker state fields
COMPLETION_FILE="$WORKTREE_ROOT/.opencode/skills/approval-gate/tasks/completion.md"
if [ ! -f "$COMPLETION_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — completion.md not found"
    OVERALL_RESULT=1
elif ! grep -qi "blocker.state\|Blocker state\|developer.action.required\|Developer action required" "$COMPLETION_FILE"; then
    echo "FAIL: $SCENARIO_NAME — completion.md missing blocker state / developer action required fields"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — completion.md has blocker state fields"
fi

# Verify 3: Chat output format includes Blockers element
if ! grep -qi "Blockers" "$CR_FILE"; then
    echo "FAIL: $SCENARIO_NAME — 000-critical-rules.md chat output format missing Blockers element"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — 000-critical-rules.md chat output format includes Blockers"
fi

if [ $OVERALL_RESULT -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME — all checks passed"
else
    echo "FAIL: $SCENARIO_NAME — one or more checks failed"
fi

exit $OVERALL_RESULT
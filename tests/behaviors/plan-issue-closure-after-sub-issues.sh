#!/bin/bash
# Behavioral Enforcement Test: Plan Issue Closure After All Sub-Issues Verified Complete
#
# Verifies that when all sub-issues of a plan are verified complete and closed,
# the agent closes the parent plan issue with a verification comment.
#
# This test checks BOTH behavioral enforcement (agent behavior prompt) AND
# content-verification (guideline and task file content) for the critical
# violation "Parent Issue Left Open After All Children Closed".
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$WORKTREE_ROOT")" != ".opencode" ]; do
    WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"
done
WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"

SCENARIO_NAME="plan-issue-closure-after-sub-issues"
SCENARIO_PROMPT="All sub-issues of my plan are closed and verified complete. Should I close the parent plan issue?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Content-verification checks (primary enforcement gate)

# Verify 1: 000-critical-rules.md contains the "Parent Issue Left Open" critical violation
CRITICAL_RULES_FILE="$WORKTREE_ROOT/.opencode/guidelines/000-critical-rules.md"
if [ ! -f "$CRITICAL_RULES_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — $CRITICAL_RULES_FILE not found"
    OVERALL_RESULT=1
else
    if ! grep -q 'Parent Issue Left Open After All Children Closed' "$CRITICAL_RULES_FILE"; then
        echo "FAIL: $SCENARIO_NAME — Critical violation section 'Parent Issue Left Open After All Children Closed' not found in 000-critical-rules.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Critical violation section found in 000-critical-rules.md"
    fi

    if ! grep -q 'critical-rules-039' "$CRITICAL_RULES_FILE"; then
        echo "FAIL: $SCENARIO_NAME — yaml+symbolic rule critical-rules-039 not found in 000-critical-rules.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — yaml+symbolic rule critical-rules-039 found in 000-critical-rules.md"
    fi

    if ! grep -q 'Leaving a parent issue open after all child issues are closed' "$CRITICAL_RULES_FILE"; then
        echo "FAIL: $SCENARIO_NAME — FORBIDDEN entry for leaving parent open not found"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — FORBIDDEN entry for leaving parent open found"
    fi

    if ! grep -q 'close the parent plan issue' "$CRITICAL_RULES_FILE"; then
        echo "FAIL: $SCENARIO_NAME — REQUIRED entry for closing parent plan not found"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — REQUIRED entry for closing parent plan found"
    fi
fi

# Verify 2: verify-already-implemented.md contains Step 6 parent plan closure
VAI_FILE="$WORKTREE_ROOT/.opencode/skills/approval-gate/tasks/verify-already-implemented.md"
if [ ! -f "$VAI_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — $VAI_FILE not found"
    OVERALL_RESULT=1
else
    if ! grep -q 'Step 6: Parent Plan Closure Check' "$VAI_FILE"; then
        echo "FAIL: $SCENARIO_NAME — Step 6 'Parent Plan Closure Check' not found in verify-already-implemented.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Step 6 'Parent Plan Closure Check' found in verify-already-implemented.md"
    fi

    if ! grep -q 'close the parent plan issue' "$VAI_FILE"; then
        echo "FAIL: $SCENARIO_NAME — Parent plan closure instruction not found in verify-already-implemented.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Parent plan closure instruction found in verify-already-implemented.md"
    fi
fi

# Verify 3: cleanup.md contains Step 2.8 parent plan closure
CLEANUP_FILE="$WORKTREE_ROOT/.opencode/skills/git-workflow/tasks/cleanup.md"
if [ ! -f "$CLEANUP_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — $CLEANUP_FILE not found"
    OVERALL_RESULT=1
else
    if ! grep -q 'Step 2.8: Parent Plan Closure' "$CLEANUP_FILE"; then
        echo "FAIL: $SCENARIO_NAME — Step 2.8 'Parent Plan Closure' not found in cleanup.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Step 2.8 'Parent Plan Closure' found in cleanup.md"
    fi

    if ! grep -q 'Parent issues MUST be closed after ALL child issues are verified complete' "$CLEANUP_FILE"; then
        echo "FAIL: $SCENARIO_NAME — REQUIRED statement about closing parents after children verified not found in cleanup.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — REQUIRED statement about closing parents found in cleanup.md"
    fi
fi

# Verify 4: 000-critical-rules.md cross-references both task files
if [ ! -f "$CRITICAL_RULES_FILE" ]; then
    echo "SKIP: $SCENARIO_NAME — Cross-reference check skipped (critical rules file not found)"
else
    if ! grep -q 'verify-already-implemented.*Step 6' "$CRITICAL_RULES_FILE" && ! grep -q 'approval-gate.*verify-already-implemented.*Step 6' "$CRITICAL_RULES_FILE"; then
        echo "FAIL: $SCENARIO_NAME — Cross-reference to verify-already-implemented Step 6 not found in 000-critical-rules.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Cross-reference to verify-already-implemented Step 6 found"
    fi

    if ! grep -q 'cleanup.*Step 2.8' "$CRITICAL_RULES_FILE" && ! grep -q 'git-workflow.*cleanup.*Step 2.8' "$CRITICAL_RULES_FILE"; then
        echo "FAIL: $SCENARIO_NAME — Cross-reference to cleanup Step 2.8 not found in 000-critical-rules.md"
        OVERALL_RESULT=1
    else
        echo "PASS: $SCENARIO_NAME — Cross-reference to cleanup Step 2.8 found"
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
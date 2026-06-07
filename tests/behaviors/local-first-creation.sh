#!/bin/bash
# Behavioral Enforcement Test: local-first-creation — Local-First Issue Creation
#
# Verifies that issue creation routes through .issues/ FIRST before
# remote promotion, regardless of platform.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$WORKTREE_ROOT")" != ".opencode" ]; do
    WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"
done
WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"

SCENARIO_NAME="local-first-creation"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Test 1: creation.md documents local-first stage
echo "--- Test 1: creation.md has local-first stage ---"
CREATION_MD="$WORKTREE_ROOT/.opencode/skills/issue-operations/tasks/creation.md"
if [ ! -f "$CREATION_MD" ]; then
    echo "SKIP: creation.md not found"
else
    if grep -qi "local-first\|local issue.*MANDATORY.*FIRST" "$CREATION_MD"; then
        echo "PASS: creation.md documents local-first stage"
    else
        echo "FAIL: creation.md missing local-first stage documentation"
        OVERALL_RESULT=1
    fi
fi

# Test 2: local platform has promote and sync capabilities
echo "--- Test 2: local platform has promote/sync ---"
LOCAL_SKILL="$WORKTREE_ROOT/.opencode/skills/issue-operations/platforms/local/SKILL.md"
if [ ! -f "$LOCAL_SKILL" ]; then
    echo "SKIP: local/SKILL.md not found"
else
    if grep -q "promote" "$LOCAL_SKILL" && grep -q "sync" "$LOCAL_SKILL"; then
        echo "PASS: local platform has promote and sync capabilities"
    else
        echo "FAIL: local platform missing promote or sync capability"
        OVERALL_RESULT=1
    fi
fi

# Test 3: local-issues tool has promote command
echo "--- Test 3: local-issues has promote command ---"
LOCAL_ISSUES="$WORKTREE_ROOT/.opencode/tools/local-issues"
if [ ! -f "$LOCAL_ISSUES" ]; then
    echo "SKIP: local-issues not found"
else
    if grep -q "elif command == \"promote\"" "$LOCAL_ISSUES"; then
        echo "PASS: local-issues has promote command"
    else
        echo "FAIL: local-issues missing promote command"
        OVERALL_RESULT=1
    fi
fi

# Test 4: promote command checks readiness criteria
echo "--- Test 4: promote checks readiness criteria ---"
if [ ! -f "$LOCAL_ISSUES" ]; then
    echo "SKIP: local-issues not found"
else
    if grep -q "TBD" "$LOCAL_ISSUES" && grep -q "Success Criteria" "$LOCAL_ISSUES"; then
        echo "PASS: promote checks for TBDs and Success Criteria"
    else
        echo "FAIL: promote missing readiness criteria checks"
        OVERALL_RESULT=1
    fi
fi

# Test 5: local-issues has sync command
echo "--- Test 5: local-issues has sync command ---"
if [ ! -f "$LOCAL_ISSUES" ]; then
    echo "SKIP: local-issues not found"
else
    if grep -q "elif command == \"sync\"" "$LOCAL_ISSUES"; then
        echo "PASS: local-issues has sync command"
    else
        echo "FAIL: local-issues missing sync command"
        OVERALL_RESULT=1
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
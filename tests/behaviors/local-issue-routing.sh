#!/bin/bash
# Behavioral Enforcement Test: Local Issue Routing
#
# Verifies that the issue-operations skill includes a 'local' platform
# routing option and that the local-issues tool exists and operates.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

WORKTREE_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

SCENARIO_NAME="local-issue-routing"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Resolve paths — .opencode/ is always a submodule, so paths are
# .opencode/tools/..., .opencode/skills/..., etc.
# In a submodule worktree, the worktree root IS the submodule content,
# so we check both WORKTREE_ROOT/.opencode/... and WORKTREE_ROOT/...
resolve_path() {
    local rel_path="$1"
    if [ -f "$WORKTREE_ROOT/.opencode/$rel_path" ]; then
        echo "$WORKTREE_ROOT/.opencode/$rel_path"
    elif [ -f "$WORKTREE_ROOT/$rel_path" ]; then
        echo "$WORKTREE_ROOT/$rel_path"
    else
        echo ""
    fi
}

# Test 1: local-issues tool exists and is executable
echo "--- Test 1: local-issues tool exists and is executable ---"
LOCAL_ISSUES_TOOL=$(resolve_path "tools/local-issues")
if [ -n "$LOCAL_ISSUES_TOOL" ] && [ -x "$LOCAL_ISSUES_TOOL" ]; then
    echo "PASS: local-issues tool exists and is executable at $LOCAL_ISSUES_TOOL"
else
    echo "FAIL: local-issues tool not found or not executable"
    if [ -n "$LOCAL_ISSUES_TOOL" ]; then
        echo "  Found at $LOCAL_ISSUES_TOOL but not executable (chmod +x needed?)"
    fi
    OVERALL_RESULT=1
fi

# Test 2: local-issues create command
echo "--- Test 2: local-issues create command ---"
if [ -n "$LOCAL_ISSUES_TOOL" ] && [ -x "$LOCAL_ISSUES_TOOL" ]; then
    TEST_DIR=$(mktemp -d)
    cd "$TEST_DIR"
    git init -q
    git commit -q --allow-empty -m "init"

    CREATE_OUTPUT=$("$LOCAL_ISSUES_TOOL" create --title "Test issue" --labels SPEC 2>&1) || CREATE_EXIT=$?
    CREATE_EXIT=${CREATE_EXIT:-0}

    if [ "$CREATE_EXIT" -eq 0 ]; then
        echo "PASS: local-issues create exited 0"

        # Verify directory structure
        if [ -d ".issues/open/001-test-issue" ] && [ -f ".issues/open/001-test-issue/spec.md" ]; then
            echo "PASS: Issue directory and spec.md created"
        else
            echo "FAIL: Issue directory or spec.md not created"
            OVERALL_RESULT=1
        fi

        # Verify counter incremented
        COUNTER=$(cat .issues/.counter)
        if [ "$COUNTER" -eq 2 ]; then
            echo "PASS: Counter incremented to 2"
        else
            echo "FAIL: Counter is $COUNTER, expected 2"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: local-issues create exited $CREATE_EXIT"
        echo "Output: $CREATE_OUTPUT"
        OVERALL_RESULT=1
    fi

    cd /
    rm -rf "$TEST_DIR"
else
    echo "SKIP: local-issues tool not available, skipping create test"
fi

# Test 3: issue-operations SKILL.md includes local platform route
echo "--- Test 3: issue-operations skill includes local platform ---"
SKILL_FILE=$(resolve_path "skills/issue-operations/SKILL.md")
if [ -n "$SKILL_FILE" ] && [ -f "$SKILL_FILE" ]; then
    if grep -q "local" "$SKILL_FILE" && grep -q "platforms/local" "$SKILL_FILE"; then
        echo "PASS: issue-operations SKILL.md includes local platform routing"
    else
        echo "FAIL: issue-operations SKILL.md missing local platform routing"
        OVERALL_RESULT=1
    fi
else
    echo "FAIL: issue-operations SKILL.md not found"
    OVERALL_RESULT=1
fi

# Test 4: local platform SKILL.md exists
echo "--- Test 4: local platform SKILL.md exists ---"
LOCAL_SKILL=$(resolve_path "skills/issue-operations/platforms/local/SKILL.md")
if [ -n "$LOCAL_SKILL" ] && [ -f "$LOCAL_SKILL" ]; then
    echo "PASS: platforms/local/SKILL.md exists"
else
    echo "FAIL: platforms/local/SKILL.md not found"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
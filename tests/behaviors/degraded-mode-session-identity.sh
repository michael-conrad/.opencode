#!/bin/bash
# Behavioral Enforcement Test: Degraded-Mode Session Identity
#
# Verifies that session-init and session_context_identity.py do NOT exit 1
# when a repo has no git remote. Instead, they should emit degraded-mode
# identity (github.platform: local, github.identity_source: none) and exit 0.
#
# RED state: These scripts currently exit 1 when no remote is configured.
# After implementation, they should exit 0 with degraded-mode output.
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

SCENARIO_NAME="degraded-mode-session-identity"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# Resolve tool paths — .opencode/ is always a submodule, so paths are
# .opencode/tools/..., .opencode/scripts/..., etc.
# In a submodule worktree, the worktree root IS the submodule content,
# so we check both WORKTREE_ROOT/.opencode/... and WORKTREE_ROOT/...
resolve_tool() {
    local rel_path="$1"
    if [ -f "$WORKTREE_ROOT/.opencode/$rel_path" ]; then
        echo "$WORKTREE_ROOT/.opencode/$rel_path"
    elif [ -f "$WORKTREE_ROOT/$rel_path" ]; then
        echo "$WORKTREE_ROOT/$rel_path"
    else
        echo ""
    fi
}

# Use a temporary git repo with no remote as test environment
TEST_REPO=$(mktemp -d)
cd "$TEST_REPO"
git init -q
git commit -q --allow-empty -m "init"

# Test 1: session-init exits 0 when no remote exists
echo "--- Test 1: session-init exits 0 with no remote ---"
SESSION_INIT=$(resolve_tool "tools/session-init")
if [ -z "$SESSION_INIT" ] || [ ! -f "$SESSION_INIT" ]; then
    echo "SKIP: session-init not found"
    cd /
    rm -rf "$TEST_REPO"
    exit 0
fi

OUTPUT=$(cd "$TEST_REPO" && "$SESSION_INIT" 2>/dev/null) || EXIT_CODE=$?
EXIT_CODE=${EXIT_CODE:-0}

if [ "$EXIT_CODE" -eq 0 ]; then
    echo "PASS: session-init exits 0 when no remote (got exit code $EXIT_CODE)"
else
    echo "FAIL: session-init exits $EXIT_CODE when no remote (expected 0)"
    echo "Output: $OUTPUT"
    OVERALL_RESULT=1
fi

# Test 2: session-init emits github.platform: local when no remote
echo "--- Test 2: session-init emits github.platform: local ---"
if echo "$OUTPUT" | grep -q "github.platform: local"; then
    echo "PASS: github.platform: local found in output"
else
    echo "FAIL: github.platform: local NOT found in output"
    echo "Output was:"
    echo "$OUTPUT"
    OVERALL_RESULT=1
fi

# Test 3: session-init emits github.identity_source: none when no remote
echo "--- Test 3: session-init emits github.identity_source: none ---"
if echo "$OUTPUT" | grep -q "github.identity_source: none"; then
    echo "PASS: github.identity_source: none found in output"
else
    echo "FAIL: github.identity_source: none NOT found in output"
    OVERALL_RESULT=1
fi

# Test 4: session_context_identity.py exits 0 when no remote
echo "--- Test 4: session_context_identity.py exits 0 with no remote ---"
IDENTITY_SCRIPT=$(resolve_tool "scripts/session_context_identity.py")
if [ -z "$IDENTITY_SCRIPT" ] || [ ! -f "$IDENTITY_SCRIPT" ]; then
    echo "SKIP: session_context_identity.py not found"
else
    ID_OUTPUT=$(cd "$TEST_REPO" && uv run "$IDENTITY_SCRIPT" 2>/dev/null) || ID_EXIT=$?
    ID_EXIT=${ID_EXIT:-0}
    if [ "$ID_EXIT" -eq 0 ]; then
        echo "PASS: session_context_identity.py exits 0 when no remote (got $ID_EXIT)"
    else
        echo "FAIL: session_context_identity.py exits $ID_EXIT when no remote (expected 0)"
        OVERALL_RESULT=1
    fi
fi

# Test 5: session_context_triggers.py exits 0 when no remote
echo "--- Test 5: session_context_triggers.py exits 0 with no remote ---"
TRIGGERS_SCRIPT=$(resolve_tool "scripts/session_context_triggers.py")
if [ -z "$TRIGGERS_SCRIPT" ] || [ ! -f "$TRIGGERS_SCRIPT" ]; then
    echo "SKIP: session_context_triggers.py not found"
else
    TR_OUTPUT=$(cd "$TEST_REPO" && uv run "$TRIGGERS_SCRIPT" 2>/dev/null) || TR_EXIT=$?
    TR_EXIT=${TR_EXIT:-0}
    if [ "$TR_EXIT" -eq 0 ]; then
        echo "PASS: session_context_triggers.py exits 0 when no remote (got $TR_EXIT)"
    else
        echo "FAIL: session_context_triggers.py exits $TR_EXIT when no remote (expected 0)"
        OVERALL_RESULT=1
    fi
fi

# Cleanup
cd /
rm -rf "$TEST_REPO"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
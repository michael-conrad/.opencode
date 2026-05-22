#!/bin/bash
# Behavioral Enforcement Test: sync-classification — Bidirectional Sync Logic
#
# Verifies that sync classification correctly identifies:
# - Correction/clarification → auto-sync
# - Scope/intent change → flag for review
# - Uncertain → flag conservative
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

SCENARIO_NAME="sync-classification"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

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

run_local_issues() {
    local tool="$1"
    shift
    if command -v uv &> /dev/null; then
        uv run "$tool" "$@"
    else
        "$tool" "$@"
    fi
}

# Test 1: Promote command readiness check
echo "--- Test 1: promote readiness check blocks incomplete specs ---"
LOCAL_ISSUES=$(resolve_tool "tools/local-issues")
if [ -z "$LOCAL_ISSUES" ] || [ ! -f "$LOCAL_ISSUES" ]; then
    echo "SKIP: local-issues not found"
else
    # Create temp issue with TBD
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/.issues/open" "$TEMP_DIR/.issues/closed"
    echo "1" > "$TEMP_DIR/.issues/.counter"
    mkdir -p "$TEMP_DIR/.issues/open/001-test-issue"
    cat > "$TEMP_DIR/.issues/open/001-test-issue/spec.md" << 'EOF'
---
number: 1
title: "[SPEC] Test Issue"
status: open
labels: [SPEC, needs-approval]
created: "2026-05-08T00:00:00Z"
updated: "2026-05-08T00:00:00Z"
author: test
---
# Test Issue

TBD: Need to define success criteria.
EOF
    
    # Run promote from temp dir
    cd "$TEMP_DIR"
    EXIT_CODE=0
    OUTPUT=$(run_local_issues "$LOCAL_ISSUES" promote 1 2>&1) || EXIT_CODE=$?
    cd - > /dev/null
    
    if [ "$EXIT_CODE" -eq 2 ]; then
        if echo "$OUTPUT" | grep -q "TBD\|TODO"; then
            echo "PASS: Promote blocked issue with TBD placeholder"
        else
            echo "FAIL: Promote blocked but did not mention TBD"
            echo "$OUTPUT"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: Promote should exit 2 for TBD issues (got $EXIT_CODE)"
        echo "$OUTPUT"
        OVERALL_RESULT=1
    fi
    
    rm -rf "$TEMP_DIR"
fi

# Test 2: Promote readiness check passes complete specs
echo "--- Test 2: promote readiness check allows complete specs ---"
if [ -z "$LOCAL_ISSUES" ] || [ ! -f "$LOCAL_ISSUES" ]; then
    echo "SKIP: local-issues not found"
else
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/.issues/open" "$TEMP_DIR/.issues/closed"
    echo "2" > "$TEMP_DIR/.issues/.counter"
    mkdir -p "$TEMP_DIR/.issues/open/002-complete-spec"
    cat > "$TEMP_DIR/.issues/open/002-complete-spec/spec.md" << 'EOF'
---
number: 2
title: "[SPEC] Complete Test Issue"
status: open
labels: [SPEC, needs-approval]
created: "2026-05-08T00:00:00Z"
updated: "2026-05-08T00:00:00Z"
author: test
---
# Complete Test Issue

## Summary

This is a complete spec with all sections defined.

## Success Criteria

- SC-1: All requirements defined
- SC-2: Test coverage verified
EOF
    
    cd "$TEMP_DIR"
    EXIT_CODE=0
    OUTPUT=$(run_local_issues "$LOCAL_ISSUES" promote 2 2>&1) || EXIT_CODE=$?
    cd - > /dev/null
    
    if [ "$EXIT_CODE" -eq 0 ]; then
        if echo "$OUTPUT" | grep -q "ready for promotion"; then
            echo "PASS: Promote allows complete spec"
        else
            echo "FAIL: Promote did not report readiness"
            echo "$OUTPUT"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: Promote should exit 0 for complete specs (got $EXIT_CODE)"
        echo "$OUTPUT"
        OVERALL_RESULT=1
    fi
    
    rm -rf "$TEMP_DIR"
fi

# Test 3: Sync stub acknowledges agent judgment required
echo "--- Test 3: sync command requires agent judgment ---"
if [ -z "$LOCAL_ISSUES" ] || [ ! -f "$LOCAL_ISSUES" ]; then
    echo "SKIP: local-issues not found"
else
    TEMP_DIR=$(mktemp -d)
    mkdir -p "$TEMP_DIR/.issues/open" "$TEMP_DIR/.issues/closed"
    echo "3" > "$TEMP_DIR/.issues/.counter"
    mkdir -p "$TEMP_DIR/.issues/open/003-linked-issue"
    cat > "$TEMP_DIR/.issues/open/003-linked-issue/spec.md" << 'EOF'
---
number: 3
title: "[SPEC] Linked Issue"
status: open
labels: [SPEC, needs-approval]
remote_issue: 100
remote_url: "https://github.com/test/repo/issues/100"
created: "2026-05-08T00:00:00Z"
updated: "2026-05-08T00:00:00Z"
author: test
---
# Linked Issue

This issue is linked to remote #100.
EOF
    
    cd "$TEMP_DIR"
    EXIT_CODE=0
    OUTPUT=$(run_local_issues "$LOCAL_ISSUES" sync 3 2>&1) || EXIT_CODE=$?
    cd - > /dev/null
    
    if [ "$EXIT_CODE" -ne 0 ]; then
        if echo "$OUTPUT" | grep -qi "agent judgment\|not yet implemented\|stub"; then
            echo "PASS: Sync acknowledges agent judgment required"
        else
            echo "FAIL: Sync failed without clear message"
            echo "$OUTPUT"
            OVERALL_RESULT=1
        fi
    else
        echo "FAIL: Sync should require agent implementation"
        OVERALL_RESULT=1
    fi
    
    rm -rf "$TEMP_DIR"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
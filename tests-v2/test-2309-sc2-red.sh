#!/bin/bash
# Content-verification test: 'Guard checks' docstring in tools/session-init no
# longer references the '.worktrees/main/' worktree bootstrap. Maps to SC-2
# from issue #2309.
#
# RED phase (Item 2, SC-2): assert the 'Guard checks' docstring in
# .opencode/tools/session-init does NOT contain '.worktrees/main/'. At baseline
# the stale line "- .worktrees/main/: Bootstrap worktree layout if not set up"
# is still present, so this assertion FAILS (RED). GREEN phase removes the
# stale line; this test then PASSES.
#
# tools/session-init is a regular tracked file in the .opencode repo (not the
# .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2309-sc2-red.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== tools/session-init 'Guard checks' docstring -- SC-2 (#2309) ==="
echo ""

SESSION_INIT="$PROJECT_DIR/tools/session-init"

# SC-2: The 'Guard checks' docstring must not reference the '.worktrees/main/'
# worktree bootstrap. At baseline the stale line is present, so this assertion
# FAILS (RED).
if grep -n 'worktrees/main' "$SESSION_INIT" 2>/dev/null; then
    check_fail "SC-2: '.worktrees/main/' absent from tools/session-init" \
        "stale reference still present (GREEN not yet applied)"
else
    check_pass "SC-2: '.worktrees/main/' absent from tools/session-init"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0

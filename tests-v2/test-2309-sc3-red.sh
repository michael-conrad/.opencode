#!/bin/bash
# Content-verification test: 'Guard checks' docstring in tools/session-init
# still references the '.env gitignore' guard check. Maps to SC-3 from issue
# #2309.
#
# RED phase (Item 3, SC-3): assert the 'Guard checks' docstring in
# .opencode/tools/session-init DOES contain '.env gitignore'. This is a
# preservation criterion — the line "- .env gitignore: Warn if .env exists but
# is not in .gitignore" is already present and must be preserved while the
# stale 'dev branch' and '.worktrees/main/' lines are removed. The assertion
# PASSES at baseline (the line is present), so this is ALREADY_GREEN: a
# failing RED test cannot be validly produced for a preservation criterion
# whose behavior is already implemented.
#
# tools/session-init is a regular tracked file in the .opencode repo (not the
# .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2309-sc3-red.sh
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
echo "=== tools/session-init 'Guard checks' docstring -- SC-3 (#2309) ==="
echo ""

SESSION_INIT="$PROJECT_DIR/tools/session-init"

# SC-3: The 'Guard checks' docstring must still reference the '.env gitignore'
# guard check. The line is present and must be preserved, so this assertion
# PASSES at baseline (ALREADY_GREEN).
if grep -n '.env gitignore' "$SESSION_INIT" 2>/dev/null; then
    check_pass "SC-3: '.env gitignore' present in tools/session-init"
else
    check_fail "SC-3: '.env gitignore' present in tools/session-init" \
        "line missing (preservation criterion not met)"
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

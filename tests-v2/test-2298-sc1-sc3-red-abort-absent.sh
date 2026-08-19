#!/bin/bash
# Content-verification test: classified-abort terminal state and RED classifications absent from red.md
# Maps to SC-1 and SC-3 from issue #2298: .opencode/skills/test-driven-development/tasks/red.md
# must define a classified ABORT terminal state (status: BLOCKED + blocker_reason) and
# enumerate the four RED classifications (ALREADY_GREEN, FALSE_PREMISE, NOT_RELEVANT, CONFLICT).
#
# RED phase (Items 1 and 3): assert the abort terminal state and the four classifications
# are ABSENT from .opencode/skills/test-driven-development/tasks/red.md. The test passes
# while they are absent (baseline). GREEN phase adds them; this test then FAILS, confirming
# the addition, and the GREEN verify asserts they are PRESENT.
#
# red.md is a regular tracked file in the .opencode repo (not the .issues/ worktree),
# so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2298-sc1-sc3-red-abort-absent.sh
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
echo "=== red.md classified-abort terminal state + RED classifications -- SC-1, SC-3 (#2298) ==="
echo ""

RED_MD="$PROJECT_DIR/skills/test-driven-development/tasks/red.md"

# SC-1 (RED phase): the classified-abort terminal state (status: BLOCKED + blocker_reason)
# must be ABSENT from red.md before the change. After GREEN adds it, this FAILS.
if grep -q 'status: BLOCKED' "$RED_MD" 2>/dev/null || grep -q 'blocker_reason' "$RED_MD" 2>/dev/null; then
    check_fail "SC-1: classified-abort terminal state ABSENT in .opencode/skills/test-driven-development/tasks/red.md" \
        "abort terminal state (status: BLOCKED / blocker_reason) already added (GREEN applied)"
else
    check_pass "SC-1: classified-abort terminal state ABSENT in .opencode/skills/test-driven-development/tasks/red.md"
fi

# SC-3 (RED phase): the four RED classifications must be ABSENT from red.md before the
# change. After GREEN enumerates them, this FAILS.
for CLASS in ALREADY_GREEN FALSE_PREMISE NOT_RELEVANT CONFLICT; do
    if grep -q "$CLASS" "$RED_MD" 2>/dev/null; then
        check_fail "SC-3: classification '$CLASS' ABSENT in .opencode/skills/test-driven-development/tasks/red.md" \
            "classification already added (GREEN applied)"
    else
        check_pass "SC-3: classification '$CLASS' ABSENT in .opencode/skills/test-driven-development/tasks/red.md"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0

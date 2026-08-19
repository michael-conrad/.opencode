#!/bin/bash
# Content-verification test: classified-abort terminal state, GREEN classifications, and
# shuffle-to-RED routing absent from green.md
# Maps to SC-2, SC-4, SC-11 from issue #2298: .opencode/skills/test-driven-development/tasks/green.md
# must define a classified ABORT terminal state (status: BLOCKED + blocker_reason), enumerate
# the five GREEN classifications (NO_PURPOSE, IMPOSSIBLE, CONFLICT, SCOPE_CREEP,
# BAD_TEST_NEEDS_REVISION), and route BAD_TEST_NEEDS_REVISION back to RED for revision.
#
# RED phase (Items 2, 4, 11): assert the abort terminal state, the five classifications, and
# the shuffle-to-RED routing are ABSENT from .opencode/skills/test-driven-development/tasks/green.md.
# The test passes while they are absent (baseline). GREEN phase adds them; this test then FAILS,
# confirming the addition, and the GREEN verify asserts they are PRESENT.
#
# green.md is a regular tracked file in the .opencode repo (not the .issues/ worktree),
# so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2298-sc2-sc4-sc11-green-classified-abort-absent.sh
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
echo "=== green.md classified-abort terminal state + GREEN classifications + shuffle-to-RED routing -- SC-2, SC-4, SC-11 (#2298) ==="
echo ""

GREEN_MD="$PROJECT_DIR/skills/test-driven-development/tasks/green.md"

# SC-2 (RED phase): the classified-abort terminal state (status: BLOCKED + blocker_reason)
# must be ABSENT from green.md before the change. After GREEN adds it, this FAILS.
if grep -q 'status: BLOCKED' "$GREEN_MD" 2>/dev/null || grep -q 'blocker_reason' "$GREEN_MD" 2>/dev/null; then
    check_fail "SC-2: classified-abort terminal state ABSENT in .opencode/skills/test-driven-development/tasks/green.md" \
        "abort terminal state (status: BLOCKED / blocker_reason) already added (GREEN applied)"
else
    check_pass "SC-2: classified-abort terminal state ABSENT in .opencode/skills/test-driven-development/tasks/green.md"
fi

# SC-4 (RED phase): the five GREEN classifications must be ABSENT from green.md before the
# change. After GREEN enumerates them, this FAILS.
for CLASS in NO_PURPOSE IMPOSSIBLE CONFLICT SCOPE_CREEP BAD_TEST_NEEDS_REVISION; do
    if grep -q "$CLASS" "$GREEN_MD" 2>/dev/null; then
        check_fail "SC-4: classification '$CLASS' ABSENT in .opencode/skills/test-driven-development/tasks/green.md" \
            "classification already added (GREEN applied)"
    else
        check_pass "SC-4: classification '$CLASS' ABSENT in .opencode/skills/test-driven-development/tasks/green.md"
    fi
done

# SC-11 (RED phase): the BAD_TEST_NEEDS_REVISION shuffle-to-RED routing must be ABSENT from
# green.md before the change. After GREEN adds it, this FAILS.
if grep -q 'BAD_TEST_NEEDS_REVISION' "$GREEN_MD" 2>/dev/null; then
    check_fail "SC-11: shuffle-to-RED routing ABSENT in .opencode/skills/test-driven-development/tasks/green.md" \
        "BAD_TEST_NEEDS_REVISION shuffle routing already added (GREEN applied)"
else
    check_pass "SC-11: shuffle-to-RED routing ABSENT in .opencode/skills/test-driven-development/tasks/green.md"
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

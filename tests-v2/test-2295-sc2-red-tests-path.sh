#!/bin/bash
# Content-verification test: .issues/{N}/tests/ present in red.md as a valid test storage path
# Maps to SC-2 from issue #2295: .opencode/skills/test-driven-development/tasks/red.md
# no longer lists .issues/{N}/tests/ as a valid test storage path.
#
# RED phase (Item 2): assert the target path .issues/{N}/tests/ is PRESENT in
# .opencode/skills/test-driven-development/tasks/red.md. The test passes while the
# path is present (baseline). GREEN phase removes the path; this test then FAILS,
# confirming the removal, and the GREEN verify asserts the path is ABSENT.
#
# red.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2295-sc2-red-tests-path.sh
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
echo "=== red.md .issues/{N}/tests/ test storage path -- SC-2 (#2295) ==="
echo ""

RED_MD="$PROJECT_DIR/skills/test-driven-development/tasks/red.md"

# SC-2 (RED phase): .issues/{N}/tests/ must be present in red.md as a valid
# test storage path before the change. After GREEN removes it, this FAILS.
if grep -q '.issues/{N}/tests/' "$RED_MD" 2>/dev/null; then
    check_pass "SC-2: '.issues/{N}/tests/' present in .opencode/skills/test-driven-development/tasks/red.md"
else
    check_fail "SC-2: '.issues/{N}/tests/' present in .opencode/skills/test-driven-development/tasks/red.md" \
        "test storage path already removed (GREEN applied)"
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

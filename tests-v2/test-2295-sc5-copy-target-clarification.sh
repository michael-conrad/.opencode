#!/bin/bash
# Content-verification test: unambiguous copy-target description absent from create.md Step 6
# Maps to SC-5 from issue #2295: .opencode/skills/spec-creation/tasks/create.md Step 6
# must describe an unambiguous copy target — only analysis artifacts (not
# source/test/fixture) are copied to .issues/{N}/artifacts/.
#
# RED phase (Item 5): assert the unambiguous copy-target description is ABSENT from
# .opencode/skills/spec-creation/tasks/create.md Step 6. The test passes while the
# description is absent (baseline). GREEN phase adds the "only analysis artifacts,
# not source/test/fixture" language; this test then FAILS, confirming the addition,
# and the GREEN verify asserts the description is PRESENT.
#
# create.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2295-sc5-copy-target-clarification.sh
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
echo "=== create.md Step 6 unambiguous copy-target description -- SC-5 (#2295) ==="
echo ""

CREATE_MD="$PROJECT_DIR/skills/spec-creation/tasks/create.md"

# SC-5 (RED phase): the unambiguous copy-target description must be ABSENT from
# create.md Step 6 before the change. After GREEN adds the "only analysis artifacts,
# not source/test/fixture" language, this FAILS.
if grep -qi 'only analysis artifacts' "$CREATE_MD" 2>/dev/null; then
    check_fail "SC-5: unambiguous copy-target description ABSENT in .opencode/skills/spec-creation/tasks/create.md Step 6" \
        "only-analysis-artifacts language already added (GREEN applied)"
else
    check_pass "SC-5: unambiguous copy-target description ABSENT in .opencode/skills/spec-creation/tasks/create.md Step 6"
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

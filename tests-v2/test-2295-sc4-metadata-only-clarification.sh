#!/bin/bash
# Content-verification test: metadata-only clarification absent from implementation-workflow.md Rule 1
# Maps to SC-4 from issue #2295: .opencode/skills/writing-plans/reference/implementation-workflow.md
# Rule 1 clarifies .issues/{N}/ holds issue metadata only, not arbitrary source/test/fixture artifacts.
#
# RED phase (Item 4): assert the metadata-only clarification is ABSENT from
# .opencode/skills/writing-plans/reference/implementation-workflow.md Rule 1. The test
# passes while the clarification is absent (baseline). GREEN phase adds the
# metadata-only language; this test then FAILS, confirming the addition, and the
# GREEN verify asserts the clarification is PRESENT.
#
# implementation-workflow.md is a regular tracked file in the .opencode repo (not
# the .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2295-sc4-metadata-only-clarification.sh
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
echo "=== implementation-workflow.md Rule 1 metadata-only clarification -- SC-4 (#2295) ==="
echo ""

WORKFLOW_MD="$PROJECT_DIR/skills/writing-plans/reference/implementation-workflow.md"

# SC-4 (RED phase): the metadata-only clarification must be ABSENT from Rule 1
# before the change. After GREEN adds the metadata-only language, this FAILS.
if grep -q 'metadata only' "$WORKFLOW_MD" 2>/dev/null; then
    check_fail "SC-4: metadata-only clarification ABSENT in .opencode/skills/writing-plans/reference/implementation-workflow.md Rule 1" \
        "metadata-only language already added (GREEN applied)"
else
    check_pass "SC-4: metadata-only clarification ABSENT in .opencode/skills/writing-plans/reference/implementation-workflow.md Rule 1"
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

#!/bin/bash
# Content-verification test: owning-repo placement reference absent from red.md
# Maps to SC-3 from issue #2295: .opencode/skills/test-driven-development/tasks/red.md
# directs test placement by the owning-repo principle (resolve the repo owning the
# code under test, then place per that repo's conventions).
#
# RED phase (Item 3): assert the owning-repo reference is ABSENT from
# .opencode/skills/test-driven-development/tasks/red.md. The test passes while the
# reference is absent (baseline). GREEN phase adds the owning-repo principle; this
# test then FAILS, confirming the addition, and the GREEN verify asserts the
# reference is PRESENT.
#
# red.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2295-sc3-owning-repo-principle.sh
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
echo "=== red.md owning-repo placement reference -- SC-3 (#2295) ==="
echo ""

RED_MD="$PROJECT_DIR/skills/test-driven-development/tasks/red.md"

# SC-3 (RED phase): the owning-repo reference must be ABSENT from red.md before
# the change. After GREEN adds the owning-repo principle, this FAILS.
if grep -qi 'owning.repo' "$RED_MD" 2>/dev/null; then
    check_fail "SC-3: owning-repo reference ABSENT in .opencode/skills/test-driven-development/tasks/red.md" \
        "owning-repo principle already added (GREEN applied)"
else
    check_pass "SC-3: owning-repo reference ABSENT in .opencode/skills/test-driven-development/tasks/red.md"
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

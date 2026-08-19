#!/bin/bash
# Content-verification test: unconditional `git add .issues/` auto-commit present in
# .opencode/skills/git-workflow-pr/tasks/review-prep.md Step 0
# Maps to SC-6 from issue #2295: review-prep.md Step 0 must no longer auto-commit
# arbitrary dirty .issues/<N>/ files into feature PRs. The unconditional
# `git add .issues/` auto-commit is removed entirely.
#
# RED phase (Item 6): assert the unconditional `git add .issues/` auto-commit is PRESENT
# in .opencode/skills/git-workflow-pr/tasks/review-prep.md Step 0. The test passes
# while the auto-commit is present (baseline). GREEN phase removes the unconditional
# auto-commit; this test then FAILS, confirming the removal, and the GREEN verify
# asserts the auto-commit is ABSENT.
#
# review-prep.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2295-sc6-review-prep-auto-commit.sh
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
echo "=== review-prep.md Step 0 unconditional .issues/ auto-commit -- SC-6 (#2295) ==="
echo ""

REVIEW_PREP_MD="$PROJECT_DIR/skills/git-workflow-pr/tasks/review-prep.md"

# SC-6 (RED phase): the unconditional `git add .issues/` auto-commit must be PRESENT
# in review-prep.md Step 0 before the change. After GREEN removes it entirely, this
# FAILS, confirming the removal.
if grep -q 'git add .issues/' "$REVIEW_PREP_MD" 2>/dev/null; then
    check_pass "SC-6: unconditional \`git add .issues/\` auto-commit present in .opencode/skills/git-workflow-pr/tasks/review-prep.md Step 0"
else
    check_fail "SC-6: unconditional \`git add .issues/\` auto-commit present in .opencode/skills/git-workflow-pr/tasks/review-prep.md Step 0" \
        "unconditional auto-commit already removed (GREEN applied)"
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

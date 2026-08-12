#!/bin/bash
# Content-verification test: no plan-phase sub-issue sweep into PR-merge autoclose
# Maps to SC-4 from issue #2283: .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md
# MUST NOT auto-close plan-phase sub-issues on PR merge (parent autoclose preserved).
#
# RED phase: the autoclose_issues sub-issue sweep IS present — this test FAILS.
# GREEN phase: after the sub-issue collection is removed or gated, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2283-sc4-pr-autoclose-protection.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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
echo "=== PR-Autoclose No-Sub-Issue-Sweep -- SC-4 (#2283) ==="
echo ""

CREATE_PR_FILE="$PROJECT_DIR/.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md"

# SC-4: no sub-issue sweep into autoclose_issues — the sub["number"] collection
# that appended every plan-phase sub-issue to the PR-merge autoclose list.
if grep -q 'sub\["number"\]' "$CREATE_PR_FILE" 2>/dev/null; then
    check_fail "SC-4: no sub-issue sweep into autoclose_issues in create-pr.md" "sub-issue autoclose collection still present"
else
    check_pass "SC-4: no sub-issue sweep into autoclose_issues in create-pr.md"
fi

# SC-4: autoclose_issues must not be built by concatenating the sub_issues list
if grep -q 'autoclose_issues = \[<parent>\] +' "$CREATE_PR_FILE" 2>/dev/null; then
    check_fail "SC-4: no sub-issue concatenation in autoclose_issues" "autoclose_issues still concatenates sub-issues"
else
    check_pass "SC-4: no sub-issue concatenation in autoclose_issues"
fi

# SC-4: parent autoclose preserved — autoclose_issues must still reference <parent>
if grep -q '<parent>' "$CREATE_PR_FILE" 2>/dev/null; then
    check_pass "SC-4: parent autoclose preserved (autoclose_issues still references <parent>)"
else
    check_fail "SC-4: parent autoclose preserved" "no <parent> reference found in create-pr.md autoclose logic"
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

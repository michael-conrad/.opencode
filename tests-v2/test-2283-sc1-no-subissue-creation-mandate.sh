#!/bin/bash
# Content-verification test: no sub-issue creation mandate in branch-finishing checklist
# Maps to SC-1 from issue #2283: the Sub-Issue Linkage Verification section in
# .opencode/skills/finishing-a-development-branch/tasks/checklist.md MUST NOT instruct
# creating sub-issues for plan phases at branch-finishing time.
#
# RED phase: the link-sub-issue creation mandate IS present — this test FAILS.
# GREEN phase: after the mandate is removed or rewritten, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2283-sc1-no-subissue-creation-mandate.sh
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
echo "=== Branch-Finishing No-Sub-Issue-Creation -- SC-1 (#2283) ==="
echo ""

CHECKLIST_FILE="$PROJECT_DIR/.opencode/skills/finishing-a-development-branch/tasks/checklist.md"

# SC-1: no link-sub-issue instruction anywhere in checklist.md
COUNT=$(grep -c "link-sub-issue" "$CHECKLIST_FILE" 2>/dev/null || true)
if [ "$COUNT" -eq 0 ]; then
    check_pass "SC-1: no 'link-sub-issue' instruction in checklist.md"
else
    check_fail "SC-1: no 'link-sub-issue' instruction in checklist.md" "grep count = $COUNT — creation mandate still present"
fi

# SC-1: no "create missing linkages" creation directive
if grep -q "create missing linkages" "$CHECKLIST_FILE" 2>/dev/null; then
    check_fail "SC-1: no 'create missing linkages' directive in checklist.md" "creation directive still present"
else
    check_pass "SC-1: no 'create missing linkages' directive in checklist.md"
fi

# SC-1: no get_sub_issues phase-count verification gate
if grep -q "get_sub_issues" "$CHECKLIST_FILE" 2>/dev/null; then
    check_fail "SC-1: no get_sub_issues phase-count gate in checklist.md" "phase-count verification gate still present"
else
    check_pass "SC-1: no get_sub_issues phase-count gate in checklist.md"
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

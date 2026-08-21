#!/bin/bash
# Content-verification test: .opencode#2308 SC-1 — cleanup.md zero residual 'dev' references
# Maps to SC-1 from issue #2308:
#   .opencode/skills/git-workflow-cleanup/tasks/cleanup.md contains zero residual
#   hardcoded 'dev' trunk/tip references; all 5 residual references (lines 109, 141,
#   146, 180, 327) are replaced with $DEFAULT_BRANCH or neutral terminology.
#
# Evidence type: structural — grep for residual 'dev' references in cleanup.md.
#
# RED state: cleanup.md currently contains residual hardcoded 'dev' references
# (lines 109, 141, 146, 327 match the grep pattern). The assertion below asserts
# ZERO matches; it FAILS now (RED) and PASSES after the GREEN replacement.
#
# cleanup.md is a regular tracked file in the .opencode repo (not the .issues/
# worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2308-sc1-dev-references.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

CLEANUP_MD="$PROJECT_DIR/skills/git-workflow-cleanup/tasks/cleanup.md"

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
echo "=== SC-1: cleanup.md zero residual hardcoded 'dev' trunk/tip references (#2308) ==="
echo ""
echo "Target file: $CLEANUP_MD"
echo ""

# SC-1: The task card MUST contain zero residual hardcoded 'dev' trunk/tip
# references matching the spec's grep pattern. Any match fails the SC.
if grep -nE "origin/dev|local dev|at dev|to dev|dev tip|dev HEAD|dev synced" "$CLEANUP_MD" 2>/dev/null; then
    check_fail "SC-1: zero residual hardcoded 'dev' references in cleanup.md" \
        "residual 'dev' references found above (RED phase expected)"
else
    check_pass "SC-1: zero residual hardcoded 'dev' references in cleanup.md"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-1 (#2308) residual 'dev' references not yet replaced."
    echo "cleanup.md still contains hardcoded 'dev' trunk/tip references."
    echo ""
    exit 1
fi
exit 0

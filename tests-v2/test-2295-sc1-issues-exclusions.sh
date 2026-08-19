#!/bin/bash
# Content-verification test: exclusions list present in .opencode/.issues/AGENTS.md
# Maps to SC-1 from issue #2295: .opencode/.issues/AGENTS.md contains an explicit
# exclusions list stating .issues/ holds issue metadata only, never source/test/fixture/code.
#
# RED phase: the exclusions-list marker ("never source/test/fixture/code") is ABSENT
# from .opencode/.issues/AGENTS.md — this test FAILS.
# GREEN phase: after the exclusions list is added, this test PASSES.
#
# The .issues/ path is a git worktree (orphan branch), NOT a regular directory.
# It must be read via git -C on the worktree, never via direct file tools.
#
# Usage: bash .opencode/tests-v2/test-2295-sc1-issues-exclusions.sh
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
echo "=== Issues Worktree Exclusions List -- SC-1 (#2295) ==="
echo ""

ISSUES_AGENTS="$PROJECT_DIR/.issues"

# SC-1: exclusions-list marker must be present in .opencode/.issues/AGENTS.md
if git -C "$ISSUES_AGENTS" grep -q 'never source/test/fixture/code' AGENTS.md 2>/dev/null; then
    check_pass "SC-1: exclusions-list marker 'never source/test/fixture/code' present in .opencode/.issues/AGENTS.md"
else
    check_fail "SC-1: exclusions-list marker 'never source/test/fixture/code' present in .opencode/.issues/AGENTS.md" "exclusions list not yet added"
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

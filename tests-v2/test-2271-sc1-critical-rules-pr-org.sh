#!/bin/bash
# Content-verification test: critical-rules-PR-ORG present in 000-critical-rules.md
# Maps to SC-1 from issue #2271: the "Stacked PR Is the Only Valid Organization"
# rule MUST exist in .opencode/guidelines/000-critical-rules.md.
#
# RED phase: the rule does NOT exist yet (grep count = 0) — this test FAILS.
# GREEN phase: after the rule is promoted to the canonical location, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2271-sc1-critical-rules-pr-org.sh
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
echo "=== Critical Rules PR-ORG -- SC-1 (#2271) ==="
echo ""

RULES_FILE="$PROJECT_DIR/.opencode/guidelines/000-critical-rules.md"

# SC-1: critical-rules-PR-ORG identifier present in 000-critical-rules.md
COUNT=$(grep -c "critical-rules-PR-ORG" "$RULES_FILE" 2>/dev/null || true)
if [ "$COUNT" -ge 1 ]; then
    check_pass "SC-1: critical-rules-PR-ORG present in 000-critical-rules.md ($COUNT matches)"
else
    check_fail "SC-1: critical-rules-PR-ORG present in 000-critical-rules.md" "grep count = 0 — rule not promoted to canonical location"
fi

# SC-1: bright-line heading "Stacked PR Is the Only Valid Organization" present
if grep -q "Stacked PR Is the Only Valid Organization" "$RULES_FILE" 2>/dev/null; then
    check_pass "SC-1: bright-line heading 'Stacked PR Is the Only Valid Organization' present"
else
    check_fail "SC-1: bright-line heading 'Stacked PR Is the Only Valid Organization' present" "heading not found"
fi

# SC-1: one-branch / N-commits / one-PR bright-line text present
if grep -q "one branch, N commits, one PR" "$RULES_FILE" 2>/dev/null; then
    check_pass "SC-1: 'one branch, N commits, one PR' bright-line text present"
else
    check_fail "SC-1: 'one branch, N commits, one PR' bright-line text present" "text not found"
fi

# SC-1: N-branches-for-N-issues critical-violation language present
if grep -q "N branches for N issues" "$RULES_FILE" 2>/dev/null; then
    check_pass "SC-1: 'N branches for N issues' critical-violation language present"
else
    check_fail "SC-1: 'N branches for N issues' critical-violation language present" "text not found"
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

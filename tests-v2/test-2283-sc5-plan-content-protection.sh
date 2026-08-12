#!/bin/bash
# Content-verification test: no plan phase prose posted to sub-issue bodies
# Maps to SC-5 from issue #2283: .opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md
# MUST NOT compose plan phase prose (Field/Value tables, Context YAML blocks, Procedure steps)
# into public sub-issue bodies. Plan files live only in the local .issues/{N}/ spec folder.
#
# RED phase: link-sub-issue.md still composes plan phase prose ("Parent Plan" markers,
# phase_prose variables, "Extract Phase Prose from Plan Body" step) — this test FAILS.
# GREEN phase: after body composition becomes metadata-only, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2283-sc5-plan-content-protection.sh
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
echo "=== Plan-Content Protection -- SC-5 (#2283) ==="
echo ""

LINK_SUB_ISSUE_FILE="$PROJECT_DIR/.opencode/skills/issue-operations-sub-issues/tasks/link-sub-issue.md"

# SC-5: no "Parent Plan" plan-prose composition marker in sub-issue body templates
if grep -q 'Parent Plan' "$LINK_SUB_ISSUE_FILE" 2>/dev/null; then
    check_fail "SC-5: no 'Parent Plan' plan-prose composition marker in link-sub-issue.md" "plan phase prose still posted to sub-issue bodies"
else
    check_pass "SC-5: no 'Parent Plan' plan-prose composition marker in link-sub-issue.md"
fi

# SC-5: no phase_prose variable composition in sub-issue body templates
if grep -q 'phase_prose' "$LINK_SUB_ISSUE_FILE" 2>/dev/null; then
    check_fail "SC-5: no phase_prose variable composition in link-sub-issue.md" "plan phase prose still embedded via phase_prose variable"
else
    check_pass "SC-5: no phase_prose variable composition in link-sub-issue.md"
fi

# SC-5: no "Extract Phase Prose from Plan Body" step (Step 3)
if grep -q 'Extract Phase Prose from Plan Body' "$LINK_SUB_ISSUE_FILE" 2>/dev/null; then
    check_fail "SC-5: no 'Extract Phase Prose from Plan Body' step in link-sub-issue.md" "plan prose extraction step still present"
else
    check_pass "SC-5: no 'Extract Phase Prose from Plan Body' step in link-sub-issue.md"
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

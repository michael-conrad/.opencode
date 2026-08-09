#!/bin/bash
# Content-Verification Enforcement Test: SC-7 — Corrected Label Guidance in Downstream Docs
#
# Issue: .opencode#2257 — Capability split: issue-level vs repo-level label operations.
# Phase: GREEN — SC-7 (string),
#        `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md`
#        and `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md`.
#
# SC-7 (string): `issue-operations.md` and `mcp-operations.md` SHALL document corrected
#   label guidance matching the Phase 1 verified truth
#   (`.opencode/tests-v2/behaviors/2257-capability-split.yaml`):
#   `issue_level_label_mutation: WORKING`, `repo_level_label_crud: WORKING`.
#   Specifically, both docs SHALL NOT claim post-creation label APIs are BROKEN, SHALL NOT
#   claim labels can ONLY be set during `gb issue create --label`, and SHALL NOT present the
#   "delete and recreate the issue" workaround as the path for label mutation.
#
# RED state:
#   - issue-operations.md lines 111-124 claim "Post-creation label APIs are BROKEN in
#     GitBucket", "Labels can ONLY be reliably set during gb issue create --label", and
#     "Workaround: Delete and recreate the issue if labels need to change". The Tool
#     Selection table (lines 193-196) marks Add/Replace/Remove/Remove-all labels BROKEN.
#   - mcp-operations.md lines 115-125 claim "Labels Can ONLY Be Set During Creation",
#     "GitBucket does not support adding labels after issue creation", and
#     "BROKEN: Cannot change labels after creation".
#
#   Assertions (a)-(d) below FAIL against the current BROKEN claims. GREEN rewrites both
#   docs' label sections to document WORKING post-creation label mutation.
#
# Evidence type: SC-7 is a `string` SC. This content-verification test greps both downstream
#   docs for the corrected WORKING status. It is the primary gate for this documentation-only
#   SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2257-sc7-downstream-docs.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-7).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

ISSUE_OPS_MD="$PROJECT_DIR/.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/issue-operations.md"
MCP_OPS_MD="$PROJECT_DIR/.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/mcp-operations.md"

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
    echo "  FAIL: $label — $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# grep_assert_present: pattern must appear at least once in the file.
grep_assert_present() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qF "$pattern" "$file" 2>/dev/null; then
        check_pass "$label"
    else
        check_fail "$label" "pattern '$pattern' not found in $file"
    fi
}

# grep_assert_absent: pattern must NOT appear in the file.
grep_assert_absent() {
    local label="$1"
    local file="$2"
    local pattern="$3"
    if grep -qF "$pattern" "$file" 2>/dev/null; then
        check_fail "$label" "pattern '$pattern' found in $file"
    else
        check_pass "$label"
    fi
}

echo ""
echo "=== SC-7 — Corrected Label Guidance in Downstream Docs (Spec .opencode#2257) ==="
echo ""
echo "Target files:"
echo "  $ISSUE_OPS_MD"
echo "  $MCP_OPS_MD"
echo "Verified truth: issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING"
echo ""

# ---------------------------------------------------------------------------
# SC-7 (a): issue-operations.md no longer claims post-creation label APIs are BROKEN,
#     no longer claims labels can ONLY be set during gb issue create --label, and no
#     longer presents the "delete and recreate the issue" workaround for label mutation.
#     RED-now: lines 111-124 contain these false claims.
# ---------------------------------------------------------------------------
echo "--- SC-7 (a): issue-operations.md no longer claims labels BROKEN ---"

# SC-7: the CRITICAL banner "Post-creation label APIs are BROKEN in GitBucket" is removed.
grep_assert_absent \
    "SC-7: issue-operations.md no longer claims post-creation label APIs are BROKEN" \
    "$ISSUE_OPS_MD" \
    "Post-creation label APIs are BROKEN"

# SC-7: the claim "Labels can ONLY be reliably set during gb issue create --label" is removed.
grep_assert_absent \
    "SC-7: issue-operations.md no longer claims labels ONLY set during creation" \
    "$ISSUE_OPS_MD" \
    "Labels can ONLY be reliably set during"

# SC-7: the workaround "Delete and recreate the issue if labels need to change" is removed.
grep_assert_absent \
    "SC-7: issue-operations.md no longer routes label mutation through delete-and-recreate" \
    "$ISSUE_OPS_MD" \
    "Delete and recreate the issue if labels need to change"

# ---------------------------------------------------------------------------
# SC-7 (b): issue-operations.md documents post-creation label mutation as WORKING.
#     RED-now: the Tool Selection table marks Add/Replace/Remove/Remove-all labels as
#     "❌ BROKEN (post-creation)". GREEN marks them WORKING.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-7 (b): issue-operations.md documents post-creation label mutation as WORKING ---"

# SC-7: the Tool Selection table no longer marks post-creation label operations BROKEN.
if grep -qF '❌ BROKEN (post-creation)' "$ISSUE_OPS_MD" 2>/dev/null; then
    check_fail "SC-7: issue-operations.md no longer marks label ops BROKEN (post-creation)" \
        "Tool Selection table still contains '❌ BROKEN (post-creation)'"
else
    check_pass "SC-7: issue-operations.md no longer marks label ops BROKEN (post-creation)"
fi

# SC-7: the Tool Selection table ties post-creation label operations to a WORKING status.
if grep -qiE 'label[^\n]*WORKING|WORKING[^\n]*label' "$ISSUE_OPS_MD" 2>/dev/null; then
    check_pass "SC-7: issue-operations.md ties label operations to WORKING status"
else
    check_fail "SC-7: issue-operations.md ties label operations to WORKING status" \
        "no line ties label operations to WORKING status"
fi

# ---------------------------------------------------------------------------
# SC-7 (c): mcp-operations.md no longer claims labels can only be set during creation
#     and no longer claims GitBucket does not support adding labels after creation.
#     RED-now: lines 115-125 contain these false claims.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-7 (c): mcp-operations.md no longer claims labels BROKEN ---"

# SC-7: the header "Label Operations (Labels Can ONLY Be Set During Creation)" is removed.
grep_assert_absent \
    "SC-7: mcp-operations.md no longer claims labels ONLY set during creation" \
    "$MCP_OPS_MD" \
    "Labels Can ONLY Be Set During Creation"

# SC-7: the claim "GitBucket does not support adding labels after issue creation" is removed.
#   The claim may be written with markdown emphasis ("does **not** support"), so match
#   the stable substring "support adding labels after issue creation" with optional
#   emphasis markers preceding "support".
if grep -qE 'support adding labels after issue creation' "$MCP_OPS_MD" 2>/dev/null; then
    check_fail "SC-7: mcp-operations.md no longer claims GitBucket lacks post-creation label support" \
        "claim 'does (not) support adding labels after issue creation' found in $MCP_OPS_MD"
else
    check_pass "SC-7: mcp-operations.md no longer claims GitBucket lacks post-creation label support"
fi

# SC-7: the "❌ BROKEN: Cannot change labels after creation" line is removed.
grep_assert_absent \
    "SC-7: mcp-operations.md no longer marks post-creation label change BROKEN" \
    "$MCP_OPS_MD" \
    "Cannot change labels after creation"

# ---------------------------------------------------------------------------
# SC-7 (d): mcp-operations.md documents post-creation label mutation as WORKING,
#     matching the Phase 1 verified truth.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-7 (d): mcp-operations.md documents post-creation label mutation as WORKING ---"

# SC-7: mcp-operations.md documents `gb api` passthrough or otherwise ties label mutation
#     to a WORKING status. RED-now: only the create-time workaround is documented.
if grep -qiE 'label[^\n]*WORKING|WORKING[^\n]*label|gb api' "$MCP_OPS_MD" 2>/dev/null; then
    check_pass "SC-7: mcp-operations.md documents label mutation as WORKING"
else
    check_fail "SC-7: mcp-operations.md documents label mutation as WORKING" \
        "no line documents WORKING label mutation or gb api passthrough"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "GREEN phase expected: SC-7 (corrected label guidance in downstream docs) implemented."
    echo "issue-operations.md lines 111-124 claim post-creation label APIs are BROKEN,"
    echo "labels can ONLY be set during gb issue create --label, and recommend the"
    echo "delete-and-recreate workaround. Its Tool Selection table marks Add/Replace/Remove/"
    echo "Remove-all labels as BROKEN. mcp-operations.md lines 115-125 claim labels can only"
    echo "be set during creation and that GitBucket does not support adding labels after"
    echo "creation. The Phase 1 verified truth (.opencode/tests-v2/behaviors/2257-capability-split.yaml)"
    echo "is issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING."
    echo "GREEN rewrites both docs' label sections to document WORKING post-creation label"
    echo "mutation and removes the BROKEN claims and workaround."
    echo ""
    exit 1
fi
echo "SC-7 is GREEN — both downstream docs document the corrected WORKING label guidance."
echo ""
exit 0

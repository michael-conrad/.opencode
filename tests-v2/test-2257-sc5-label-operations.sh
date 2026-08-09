#!/bin/bash
# Content-Verification Enforcement Test: SC-5 — Corrected Issue-Level Label Operation Status
#
# Issue: .opencode#2257 — Capability split: issue-level vs repo-level label operations.
# Phase: GREEN — SC-5 (string),
#        `.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md`.
#
# SC-5 (string): `label-operations.md` SHALL document the corrected operation status
#   matching the Phase 1 verified truth (`.opencode/tests-v2/behaviors/2257-capability-split.yaml`):
#   `issue_level_label_mutation: WORKING`, `repo_level_label_crud: WORKING`.
#   Specifically, the issue-level label operations (Add Labels, Replace All Labels,
#   Remove Specific Label, Remove All Labels) SHALL be documented as WORKING via `gb api`
#   passthrough against the issue-level labels endpoint — NOT BROKEN.
#
# RED state: `label-operations.md` currently documents all four issue-level label
#   operations as BROKEN (returns `[]`, no gb command, requires `gb issue create --label`
#   workaround). Assertions (a)-(d) below FAIL. GREEN rewrites the issue-level sections to
#   document WORKING via `gb api` passthrough and removes the BROKEN markers.
#
# Evidence type: SC-5 is a `string` SC. This content-verification test greps
#   label-operations.md for the corrected WORKING status. It is the primary gate for this
#   documentation-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2257-sc5-label-operations.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-5).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

LABEL_MD="$PROJECT_DIR/.opencode/skills/issue-operations/platforms/gitbucket-api/tasks/label-operations.md"

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
echo "=== SC-5 — Corrected Issue-Level Label Operation Status (Spec .opencode#2257) ==="
echo ""
echo "Target file: $LABEL_MD"
echo "Verified truth: issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING"
echo ""

# ---------------------------------------------------------------------------
# SC-5 (a): Issue-level label operations are documented as WORKING via `gb api`
#     passthrough against the issue-level labels endpoint. The doc must reference
#     `gb api` for the issue-level labels endpoint. RED-now: no `gb api` passthrough
#     is documented — the operations are marked BROKEN with the `gb issue create --label`
#     workaround.
# ---------------------------------------------------------------------------
echo "--- SC-5 (a): issue-level label operations use gb api passthrough ---"

# SC-5: the doc documents `gb api` passthrough for issue-level label operations
# (currently MISSING → RED).
grep_assert_present \
    "SC-5: doc documents gb api passthrough for issue-level label operations" \
    "$LABEL_MD" \
    "gb api"

# ---------------------------------------------------------------------------
# SC-5 (b): Each of the four issue-level label operations (Add Labels, Replace All
#     Labels, Remove Specific Label, Remove All Labels) is documented as WORKING, not
#     BROKEN. RED-now: the "Tool Selection" table marks all four as "⚠️ BROKEN".
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-5 (b): issue-level label operations are WORKING, not BROKEN ---"

# SC-5: the "Tool Selection" table no longer marks Add Labels as BROKEN. The word
# "WORKING" must appear for issue-level label mutation (currently MISSING → RED).
grep_assert_present \
    "SC-5: doc marks issue-level label mutation as WORKING" \
    "$LABEL_MD" \
    "WORKING"

# SC-5: the BROKEN marker for issue-level Add Labels must be removed. RED-now: the
# "⚠️ BROKEN (returns `[]`)" line for Add labels is present. This grep asserts the
# corrected status — the phrase "issue-level label" must be tied to WORKING, not BROKEN.
if grep -qiE 'issue[- ]level[^\n]*label[^\n]*WORKING|WORKING[^\n]*issue[- ]level[^\n]*label' "$LABEL_MD" 2>/dev/null; then
    check_pass "SC-5: issue-level label mutation explicitly documented as WORKING"
else
    check_fail "SC-5: issue-level label mutation explicitly documented as WORKING" \
        "no line ties issue-level label mutation to WORKING status"
fi

# ---------------------------------------------------------------------------
# SC-5 (c): The BROKEN markers for the four issue-level label operations must be
#     removed. RED-now: "BROKEN" appears for Add Labels, Replace All Labels, Remove
#     Specific Label, and Remove All Labels. GREEN replaces these with WORKING status.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-5 (c): BROKEN markers for issue-level label operations removed ---"

# SC-5: the workaround text "Add labels during issue creation with gb issue create
# --label" (the BROKEN workaround) must no longer be the documented path for issue-level
# operations. RED-now: this workaround line is present. The discriminator: the doc must
# not route issue-level label mutation through the create-time workaround.
grep_assert_absent \
    "SC-5: doc no longer routes issue-level label mutation through gb issue create workaround" \
    "$LABEL_MD" \
    "Add labels during issue creation with"

# ---------------------------------------------------------------------------
# SC-5 (d): The corrected operation status matches the Phase 1 verified truth —
#     issue-level label mutation is WORKING via the issue-level labels endpoint.
#     The doc must reference the issue-level labels endpoint (POST/PUT/DELETE on
#     /repos/{owner}/{repo}/issues/{number}/labels). RED-now: the doc documents the
#     endpoint as returning an empty array and NOT adding labels.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-5 (d): issue-level labels endpoint is WORKING ---"

# SC-5: the doc documents the issue-level labels endpoint
# /repos/{owner}/{repo}/issues/{number}/labels as the functional path (currently the
# endpoint is documented only as "returns HTTP 200 with an empty array" → RED).
grep_assert_present \
    "SC-5: doc references the issue-level labels endpoint" \
    "$LABEL_MD" \
    "/issues/{number}/labels"

# SC-5: the doc no longer states the endpoint "returns HTTP 200 with an empty array but
# does NOT add labels" (the BROKEN false claim). RED-now: this false claim is present.
grep_assert_absent \
    "SC-5: doc no longer claims the issue-level labels endpoint returns an empty array" \
    "$LABEL_MD" \
    "returns HTTP 200 with an empty array"

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "GREEN phase expected: SC-5 (corrected issue-level label operation status) implemented."
    echo "label-operations.md currently documents all four issue-level label operations"
    echo "(Add Labels, Replace All Labels, Remove Specific Label, Remove All Labels) as BROKEN,"
    echo "requiring the gb issue create --label workaround and claiming the issue-level"
    echo "labels endpoint returns an empty array. The Phase 1 verified truth"
    echo "(.opencode/tests-v2/behaviors/2257-capability-split.yaml) is"
    echo "issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING."
    echo "GREEN rewrites the issue-level sections to document WORKING via gb api passthrough"
    echo "against the issue-level labels endpoint and removes the BROKEN markers."
    echo ""
    exit 1
fi
echo "SC-5 is GREEN — label-operations.md documents the corrected WORKING status."
echo ""
exit 0

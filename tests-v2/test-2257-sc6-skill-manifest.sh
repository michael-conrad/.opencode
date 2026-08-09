#!/bin/bash
# Content-Verification Enforcement Test: SC-6 — Corrected Capability Manifest Status in SKILL.md
#
# Issue: .opencode#2257 — Capability split: issue-level vs repo-level label operations.
# Phase: GREEN — SC-6 (string),
#        `.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md`.
#
# SC-6 (string): The SKILL.md capability manifest SHALL report the corrected status for
#   the "Post-creation labels" row (and any label-related rows), matching the Phase 1
#   verified truth (`.opencode/tests-v2/behaviors/2257-capability-split.yaml`):
#   `issue_level_label_mutation: WORKING`, `repo_level_label_crud: WORKING`.
#   Specifically, the "Post-creation labels" row SHALL be marked ✅ WORKING via `gb api`
#   passthrough against the issue-level labels endpoint — NOT ❌ BROKEN.
#
# RED state: SKILL.md line 45 currently reads
#   "Post-creation labels | ❌ | Returns empty array — labels NOT added".
#   Assertions (a)-(d) below FAIL. GREEN rewrites the "Post-creation labels" row to
#   report ✅ WORKING via `gb api` passthrough.
#
# Evidence type: SC-6 is a `string` SC. This content-verification test greps SKILL.md's
#   capability manifest for the corrected WORKING status. It is the primary gate for this
#   documentation-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2257-sc6-skill-manifest.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-6).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_MD="$PROJECT_DIR/.opencode/skills/issue-operations/platforms/gitbucket-api/SKILL.md"

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
echo "=== SC-6 — Corrected Capability Manifest Status in SKILL.md (Spec .opencode#2257) ==="
echo ""
echo "Target file: $SKILL_MD"
echo "Verified truth: issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING"
echo ""

# ---------------------------------------------------------------------------
# SC-6 (a): The capability manifest "Post-creation labels" row is marked WORKING, not
#     BROKEN. RED-now: line 45 reads "Post-creation labels | ❌ | Returns empty array —
#     labels NOT added". The row must be rewritten to a ✅ / WORKING status.
# ---------------------------------------------------------------------------
echo "--- SC-6 (a): Post-creation labels row is WORKING, not BROKEN ---"

# SC-6: the "Post-creation labels" row is tied to a WORKING status (✅), not a BROKEN
# (❌) marker. RED-now: the row contains ❌.
grep_assert_absent \
    "SC-6: 'Post-creation labels' row no longer marked ❌ (BROKEN)" \
    "$SKILL_MD" \
    "Post-creation labels | ❌"

# SC-6: the capability manifest no longer claims "Returns empty array — labels NOT added".
# RED-now: this false claim is present in the "Post-creation labels" row.
grep_assert_absent \
    "SC-6: manifest no longer claims post-creation labels return empty array" \
    "$SKILL_MD" \
    "Returns empty array — labels NOT added"

# ---------------------------------------------------------------------------
# SC-6 (b): The corrected "Post-creation labels" row documents WORKING via `gb api`
#     passthrough. RED-now: no `gb api` passthrough is documented for post-creation labels.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-6 (b): Post-creation labels documented as WORKING via gb api passthrough ---"

# SC-6: the manifest documents `gb api` passthrough for post-creation labels. The verified
# truth is that POST/PUT/DELETE on /repos/{owner}/{repo}/issues/{number}/labels apply labels
# via gb api passthrough (SC-2). RED-now: this passthrough is not documented for labels.
grep_assert_present \
    "SC-6: manifest documents gb api passthrough for label operations" \
    "$SKILL_MD" \
    "gb api"

# ---------------------------------------------------------------------------
# SC-6 (c): The manifest references the issue-level labels endpoint
#     /repos/{owner}/{repo}/issues/{number}/labels as the functional path. RED-now: the
#     row documents only the create-time workaround, not the issue-level endpoint.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-6 (c): issue-level labels endpoint referenced in manifest ---"

# SC-6: the manifest references the issue-level labels endpoint
# /repos/{owner}/{repo}/issues/{number}/labels as the functional path for post-creation
# label mutation. RED-now: this endpoint is absent from the capability manifest.
grep_assert_present \
    "SC-6: manifest references the issue-level labels endpoint" \
    "$SKILL_MD" \
    "/issues/{number}/labels"

# ---------------------------------------------------------------------------
# SC-6 (d): The capability manifest's label-related rows match the Phase 1 verified truth —
#     both issue-level label mutation and repo-level label CRUD are WORKING. The word
#     WORKING must appear in the label row(s) of the manifest.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-6 (d): label-related manifest rows report WORKING status ---"

# SC-6: the manifest ties label operation status to WORKING (matching the verified truth
# issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING). RED-now: the
# "Post-creation labels" row is ❌ and no label row carries a WORKING marker.
if grep -qiE 'Post[- ]creation[^\n]*label[^\n]*WORKING|WORKING[^\n]*Post[- ]creation[^\n]*label' "$SKILL_MD" 2>/dev/null; then
    check_pass "SC-6: 'Post-creation labels' row explicitly tied to WORKING status"
else
    check_fail "SC-6: 'Post-creation labels' row explicitly tied to WORKING status" \
        "no line ties 'Post-creation labels' to WORKING status"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "GREEN phase expected: SC-6 (corrected capability manifest status) implemented."
    echo "SKILL.md line 45 currently reads"
    echo "  'Post-creation labels | ❌ | Returns empty array — labels NOT added'."
    echo "The Phase 1 verified truth (.opencode/tests-v2/behaviors/2257-capability-split.yaml) is"
    echo "  issue_level_label_mutation: WORKING, repo_level_label_crud: WORKING."
    echo "GREEN rewrites the 'Post-creation labels' row to mark it ✅ WORKING via gb api"
    echo "passthrough against the issue-level labels endpoint and removes the BROKEN marker."
    echo ""
    exit 1
fi
echo "SC-6 is GREEN — SKILL.md capability manifest reports the corrected WORKING status."
echo ""
exit 0

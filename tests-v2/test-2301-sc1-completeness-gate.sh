#!/bin/bash
# Content-verification test: import-remote completeness gate present
# Maps to SC-1 from issue #2301: Modify import-remote so that when the local
# issue directory exists, it checks ALL required mirror files (spec.md,
# comments.md, remote.md, state.md, frontmatter github_issue/remote_url) and
# materializes any that are missing rather than halting on directory existence
# alone.
#
# RED phase (Phase 1): assert the completeness-gate behavior is ABSENT from
# .opencode/skills/issue-operations-sync/tasks/import-remote.md. The test FAILS
# while the completeness gate is absent (RED). GREEN phase adds the completeness
# gate; this test then PASSES, confirming the change.
#
# import-remote.md is a regular tracked file in the .opencode repo (not the
# .issues/ worktree), so it is read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2301-sc1-completeness-gate.sh
# Exit: 0 if all checks pass (completeness gate present), 1 if any check fails

# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated

set -uo pipefail

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
echo "=== import-remote completeness gate -- SC-1 (#2301) ==="
echo ""

IMPORT_REMOTE="$PROJECT_DIR/skills/issue-operations-sync/tasks/import-remote.md"

# SC-1: the completeness-gate behavior must be present. A directory-existence-only
# halt must be replaced by enumeration + materialization of the required mirror
# files (spec.md, comments.md, remote.md, state.md, frontmatter
# github_issue/remote_url). Before GREEN, this FAILS (RED) because the gate is
# absent.
REQUIRED_TERMS=(
    "materializ"
    "required mirror file"
    "spec.md"
    "comments.md"
    "remote.md"
    "state.md"
    "github_issue"
    "remote_url"
)

for term in "${REQUIRED_TERMS[@]}"; do
    if grep -qi "$term" "$IMPORT_REMOTE" 2>/dev/null; then
        check_pass "SC-1: '$term' present in import-remote.md"
    else
        check_fail "SC-1: '$term' ABSENT in import-remote.md" \
            "completeness-gate behavior not yet implemented (RED expected)"
    fi
done

# SC-3: the Edge Cases 'Issue already imported' row must reflect the
# completeness-check behavior (enumerate required mirror files, materialize
# missing, only HALT when genuinely complete) — NOT the old "HALT — report
# already imported" behavior. This is a content-verification (string/structural)
# assertion against the import-remote.md Edge Cases table (row ~line 165).
SC3_ROW_OLD_HALT="HALT — report already imported"
SC3_ROW_COMPLETENESS="Run the completeness gate"
SC3_ROW_MATERIALIZE="materialize any that are missing"
SC3_ROW_ENUMERATE="spec.md"
SC3_ROW_ENUMERATE_COMMENTS="comments.md"

if grep -qi "$SC3_ROW_OLD_HALT" "$IMPORT_REMOTE" 2>/dev/null; then
    check_fail "SC-3: Edge Cases row still reflects obsolete 'HALT — report already imported' language" \
        "row must describe completeness-gate behavior, not a directory-existence-only halt"
else
    check_pass "SC-3: Edge Cases row does NOT contain obsolete 'HALT — report already imported' language"
fi

if grep -qi "$SC3_ROW_COMPLETENESS" "$IMPORT_REMOTE" 2>/dev/null; then
    check_pass "SC-3: Edge Cases row references the completeness gate"
else
    check_fail "SC-3: Edge Cases row does not reference the completeness gate" \
        "expected 'Run the completeness gate' in the 'Issue already imported' row"
fi

if grep -qi "$SC3_ROW_MATERIALIZE" "$IMPORT_REMOTE" 2>/dev/null; then
    check_pass "SC-3: Edge Cases row describes materializing missing mirror files"
else
    check_fail "SC-3: Edge Cases row does not describe materializing missing mirror files" \
        "expected 'materialize any that are missing' in the 'Issue already imported' row"
fi

if grep -qi "$SC3_ROW_ENUMERATE" "$IMPORT_REMOTE" 2>/dev/null; then
    check_pass "SC-3: Edge Cases row enumerates required mirror file 'spec.md'"
else
    check_fail "SC-3: Edge Cases row does not enumerate required mirror file 'spec.md'" \
        "expected spec.md enumeration in the 'Issue already imported' row"
fi

if grep -qi "$SC3_ROW_ENUMERATE_COMMENTS" "$IMPORT_REMOTE" 2>/dev/null; then
    check_pass "SC-3: Edge Cases row enumerates required mirror file 'comments.md'"
else
    check_fail "SC-3: Edge Cases row does not enumerate required mirror file 'comments.md'" \
        "expected comments.md enumeration in the 'Issue already imported' row"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED expected: the completeness gate is not yet implemented in"
    echo "import-remote.md. GREEN must add it (enumerate + materialize missing"
    echo "mirror files instead of halting on directory existence alone)."
    echo ""
    exit 1
fi
echo "Every required completeness-gate term is present in import-remote.md (GREEN)."
echo ""
exit 0

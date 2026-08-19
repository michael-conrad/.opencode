#!/bin/bash
# Content-verification test: post-abort re-evaluation routing, substantive/non-substantive
# adjustment classification, and retrigger ladder absent from red.md and green.md
# Maps to SC-6, SC-7, SC-8 from issue #2298: on classified abort, the orchestrator must
# dispatch a cold-reading re-evaluation sub-agent that routes to spec-creation --task revise
# / writing-plans --task revise (SC-6); distinguish substantive (revokes plan approval,
# requires re-auth) from non-substantive (auto-revise, no re-auth) adjustments (SC-7); and
# follow the retrigger ladder — 2 same-classification aborts trigger re-decomposition
# evaluation, with spec-audit ONLY if re-decomposition is NOT the fix (SC-8).
#
# RED phase (Items 6, 7, 8): assert each construct is ABSENT from both task files.
# The test passes while they are absent (baseline). GREEN phase adds them; this test then
# FAILS, confirming the addition, and the GREEN verify asserts they are PRESENT.
#
# red.md and green.md are regular tracked files in the .opencode repo (not the .issues/
# worktree), so they are read directly with grep.
#
# Usage: bash .opencode/tests-v2/test-2298-sc6-sc7-sc8-post-abort-reeval-absent.sh
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
echo "=== red.md/green.md post-abort re-evaluation routing + adjustment classification + retrigger ladder -- SC-6, SC-7, SC-8 (#2298) ==="
echo ""

RED_MD="$PROJECT_DIR/skills/test-driven-development/tasks/red.md"
GREEN_MD="$PROJECT_DIR/skills/test-driven-development/tasks/green.md"

# SC-6 (RED phase): post-abort routing guidance directing the orchestrator to a cold-reading
# re-evaluation sub-agent that routes to spec-creation --task revise / writing-plans --task
# revise must be ABSENT from both task files. After GREEN adds it, this FAILS.
for FILE in "$RED_MD" "$GREEN_MD"; do
    if grep -Eq 'cold-reading|cold reading|re-evaluation|reevaluation|spec-creation --task revise|writing-plans --task revise' "$FILE" 2>/dev/null; then
        check_fail "SC-6: post-abort re-evaluation routing ABSENT in $(basename "$FILE")" \
            "re-evaluation / revise routing guidance already added (GREEN applied)"
    else
        check_pass "SC-6: post-abort re-evaluation routing ABSENT in $(basename "$FILE")"
    fi
done

# SC-7 (RED phase): substantive vs non-substantive adjustment classification guidance (with
# the substantive branch revoking plan approval / requiring re-auth) must be ABSENT from both
# task files. After GREEN adds it, this FAILS.
for FILE in "$RED_MD" "$GREEN_MD"; do
    if grep -Eq 'substantive|non-substantive|non_substantive|revokes plan approval|requires re-auth|re-auth' "$FILE" 2>/dev/null; then
        check_fail "SC-7: substantive/non-substantive adjustment classification ABSENT in $(basename "$FILE")" \
            "adjustment classification guidance already added (GREEN applied)"
    else
        check_pass "SC-7: substantive/non-substantive adjustment classification ABSENT in $(basename "$FILE")"
    fi
done

# SC-8 (RED phase): the retrigger ladder — 2 same-classification aborts trigger re-decomposition
# evaluation, with spec-audit ONLY if re-decomposition is NOT the fix — must be ABSENT from both
# task files. After GREEN adds it, this FAILS.
for FILE in "$RED_MD" "$GREEN_MD"; do
    if grep -Eq 'retrigger|re-decomposition|redecomposition|same-classification|same classification' "$FILE" 2>/dev/null; then
        check_fail "SC-8: retrigger ladder ABSENT in $(basename "$FILE")" \
            "retrigger ladder already added (GREEN applied)"
    else
        check_pass "SC-8: retrigger ladder ABSENT in $(basename "$FILE")"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0

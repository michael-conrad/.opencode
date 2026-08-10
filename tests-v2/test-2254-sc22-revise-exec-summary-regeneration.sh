#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-22 — Revise Exec-Summary Regeneration
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-19-revise-exec-summary-regeneration — SC-22 (string),
#        `.opencode/skills/spec-creation/tasks/revise.md`.
#
# SC-22 (string): spec-creation/tasks/revise.md SHALL regenerate the exec-summary
#   remote issue body when the spec is revised.
#
# RED state: revise.md Step 5 ("Write revised spec to remote issue body") does not
#   reference exec-summary regeneration — it only says "update the remote issue body
#   with the revised spec content" without routing to the canonical exec-summary body
#   format or regenerating the exec-summary from the revised spec. Assertions (a) and
#   (b) FAIL. GREEN regenerates the exec-summary remote issue body on revision.
#
# Evidence type: SC-22 is a `string` SC. This content-verification test greps
#   spec-creation/tasks/revise.md for the required patterns. It is the primary gate
#   for this content-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc22-revise-exec-summary-regeneration.sh
# Exit:  0 if all checks pass (GREEN), 1 if any check fails (expected RED on SC-22).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

REVISE_MD="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/revise.md"

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

echo ""
echo "=== SC-22 — Revise Exec-Summary Regeneration (Spec .opencode#2254) ==="
echo ""
echo "Target file: $REVISE_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-22 (string): spec-creation/tasks/revise.md SHALL regenerate the exec-summary
#   remote issue body when the spec is revised.
#
# (a) revise.md Step 5 references exec-summary regeneration on revision. RED-now:
#     Step 5 ("Write revised spec to remote issue body") only says "update the remote
#     issue body with the revised spec content" — it does not reference regenerating
#     the exec-summary body from the revised spec.
# ---------------------------------------------------------------------------
echo "--- SC-22 (a): revise.md Step 5 references exec-summary regeneration on revision ---"

STEP5_SECTION=$(awk '/### Step 5:/,/### Step 6: Write revised local spec/' "$REVISE_MD" 2>/dev/null || true)
EXEC_SUMMARY_COUNT=$(printf '%s' "$STEP5_SECTION" | grep -c 'exec-summary\|exec summary\|regenerat' 2>/dev/null || true)
if [ "$EXEC_SUMMARY_COUNT" -gt 0 ]; then
    check_pass "SC-22: revise.md Step 5 references exec-summary regeneration on revision ($EXEC_SUMMARY_COUNT reference(s))"
else
    check_fail "SC-22: revise.md Step 5 references exec-summary regeneration on revision" \
        "no exec-summary/regeneration reference found in the Step 5 remote issue body section of $REVISE_MD (revise does not regenerate the exec-summary remote issue body on revision)"
fi

# ---------------------------------------------------------------------------
# (b) revise.md Step 5 routes the regenerated exec-summary body to the canonical
#     exec-summary body format defined in issue-operations-core/tasks/creation.md
#     Step 5 (the same canonical format create.md routes to per SC-19). RED-now:
#     Step 5 does not reference creation.md or the canonical exec-summary body format.
# ---------------------------------------------------------------------------
echo ""
echo "--- SC-22 (b): revise.md Step 5 routes the regenerated exec-summary body to the canonical exec-summary body format (creation.md Step 5) ---"

CREATION_STEP5_COUNT=$(printf '%s' "$STEP5_SECTION" | grep -c 'creation\.md' 2>/dev/null || true)
if [ "$CREATION_STEP5_COUNT" -gt 0 ]; then
    check_pass "SC-22: revise.md Step 5 references issue-operations-core/tasks/creation.md ($CREATION_STEP5_COUNT reference(s))"
else
    check_fail "SC-22: revise.md Step 5 references issue-operations-core/tasks/creation.md" \
        "no reference to creation.md found in the Step 5 remote issue body section of $REVISE_MD (regenerated exec-summary body is not routed to the canonical exec-summary body format)"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-22 (revise exec-summary regeneration) not yet implemented."
    echo "spec-creation/tasks/revise.md Step 5 does not regenerate the exec-summary"
    echo "remote issue body on revision, and does not route the regenerated body to the"
    echo "canonical exec-summary body format (creation.md Step 5)."
    echo "GREEN regenerates the exec-summary remote issue body on revision."
    echo ""
    exit 1
fi
echo "SC-22 is GREEN — revise.md regenerates the exec-summary remote issue body on"
echo "revision and routes it to the canonical exec-summary body format."
echo ""
exit 0

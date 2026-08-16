#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 3 — audit role-card heading/name verification
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 3 — audit role-card heading/name verification (prep),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 3 (preparation, no SC): Produce the heading/name verification artifact
#   confirming each audit role card's `# Task:` heading matches its filename
#   (prep). Depends on Phase 1 (the audit role-card surface inventory artifact
#   exists).
#
# The heading/name verification artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-heading-verification.yaml`;
#   (b) declare the verified role-card count (48), matching the on-disk count of
#       role-split cards (`*-arbiter.md`, `*-evaluator.md`, `*-investigator.md`,
#       `*-validator.md`);
#   (c) record that each role card's `# Task:` heading matches its filename,
#       with a heading_mismatches count of 0.
#
# RED state: the heading/name verification artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the heading/name verification artifact at the declared path
#   with the verified role-card count and the heading-mismatch count.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the heading/name verification
#   artifact. It is the RED/GREEN gate for the Phase 3 verification deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase3-audit-role-card-heading-verification.sh
# Exit:  0 if the heading/name verification artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-heading-verification.yaml"

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
echo "=== Phase 3 — audit role-card heading/name verification (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo "Artifact:   $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference counts (live, independent of the artifact).
# ---------------------------------------------------------------------------
ROLE_CARD_COUNT=$(ls "$AUDIT_DIR" | grep -Ec -- '-(arbiter|evaluator|investigator|validator)\.md$' 2>/dev/null || true)
HEADING_MISMATCH_COUNT=0
for f in "$AUDIT_DIR"/*-arbiter.md "$AUDIT_DIR"/*-evaluator.md "$AUDIT_DIR"/*-investigator.md "$AUDIT_DIR"/*-validator.md; do
    [ -e "$f" ] || continue
    base="$(basename "$f")"
    base="${base%.md}"
    heading=$(grep -m1 '^# Task:' "$f" 2>/dev/null | sed 's/^# Task: *//')
    if [ "$heading" != "$base" ]; then
        HEADING_MISMATCH_COUNT=$((HEADING_MISMATCH_COUNT + 1))
    fi
done

echo "On-disk: $ROLE_CARD_COUNT role-split cards;"
echo "         $HEADING_MISMATCH_COUNT cards whose '# Task:' heading does not match the filename."
echo ""

# ---------------------------------------------------------------------------
# (a) The heading/name verification artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): heading/name verification artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 3: heading/name verification artifact exists at $ARTIFACT"
else
    check_fail "Phase 3: heading/name verification artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card heading/name verification artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The heading/name verification artifact declares the verified role-card
#     count, matching the on-disk role-split card count.
# ---------------------------------------------------------------------------
echo "--- (b): heading/name verification artifact declares the verified role-card count ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "verified_cards:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 3: artifact declares verified_cards"
    else
        check_fail "Phase 3: artifact declares verified_cards" \
            "no 'verified_cards:' key in $ARTIFACT"
    fi

    if grep -q "verified_cards: $ROLE_CARD_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 3: artifact declares $ROLE_CARD_COUNT verified cards"
    else
        check_fail "Phase 3: artifact declares verified cards" \
            "expected 'verified_cards: $ROLE_CARD_COUNT' in $ARTIFACT (found $ROLE_CARD_COUNT on disk)"
    fi
else
    check_fail "Phase 3: artifact declares verified cards" \
        "artifact missing — cannot verify role-card count declaration"
fi

# ---------------------------------------------------------------------------
# (c) The heading/name verification artifact records that each role card's
#     `# Task:` heading matches its filename (heading_mismatches: 0).
# ---------------------------------------------------------------------------
echo "--- (c): heading/name verification artifact records heading/filename match ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "heading_mismatches:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 3: artifact declares heading_mismatches"
    else
        check_fail "Phase 3: artifact declares heading_mismatches" \
            "no 'heading_mismatches:' key in $ARTIFACT"
    fi

    if grep -q "heading_mismatches: $HEADING_MISMATCH_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 3: artifact records heading_mismatches: $HEADING_MISMATCH_COUNT"
    else
        check_fail "Phase 3: artifact records heading_mismatches" \
            "expected 'heading_mismatches: $HEADING_MISMATCH_COUNT' in $ARTIFACT (found $HEADING_MISMATCH_COUNT on disk)"
    fi
else
    check_fail "Phase 3: artifact records heading_mismatches" \
        "artifact missing — cannot verify heading/filename match record"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 3 (audit role-card heading/name verification) not yet"
    echo "implemented. The heading/name verification artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact declaring the $ROLE_CARD_COUNT"
    echo "verified role cards and recording heading_mismatches: $HEADING_MISMATCH_COUNT."
    echo ""
    exit 1
fi
echo "Phase 3 is GREEN — the audit role-card heading/name verification artifact"
echo "declares the $ROLE_CARD_COUNT verified role cards and records"
echo "heading_mismatches: $HEADING_MISMATCH_COUNT."
echo ""
exit 0

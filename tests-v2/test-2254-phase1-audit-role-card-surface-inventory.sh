#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 1 — audit role-card surface inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 1 — audit role-card surface inventory (prep for SC-40),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 1 (preparation, no SC): Produce the audit role-card surface inventory
#   artifact enumerating the role-split cards and the monolithic references
#   that point to non-existent files (prep for SC-40).
#
# The inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-surface-inventory.yaml`;
#   (b) enumerate the role-split cards (48 role cards: `*-arbiter.md`,
#       `*-evaluator.md`, `*-investigator.md`, `*-validator.md`);
#   (c) identify the 17 monolithic references to non-existent files across the
#       7 audit domains (coherence-maintenance: 2, concern-separation: 2,
#       content-audit: 2, drift-detection: 4, guideline-audit: 2,
#       test-quality-audit: 3, verification-audit: 2).
#
# RED state: the inventory artifact does not exist yet. Assertions (a), (b),
#   and (c) FAIL because the artifact file is absent. GREEN produces the
#   inventory artifact at the declared path with the role-split card count and
#   the monolithic-reference breakdown.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the inventory artifact. It is the
#   RED/GREEN gate for the Phase 1 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase1-audit-role-card-surface-inventory.sh
# Exit:  0 if the inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-surface-inventory.yaml"

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
echo "=== Phase 1 — audit role-card surface inventory (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo "Artifact:   $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# (a) The inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 1: inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 1: inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card surface inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The inventory artifact enumerates the role-split cards.
#     The on-disk surface has 48 role-split cards; the artifact SHALL record
#     that count and the role-split card filenames.
# ---------------------------------------------------------------------------
echo "--- (b): inventory artifact enumerates the role-split cards ---"

ROLE_CARD_COUNT=$(ls "$AUDIT_DIR" | grep -Ec -- '-(arbiter|evaluator|investigator|validator)\.md$' 2>/dev/null || true)

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_cards:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 1: artifact declares role_split_cards"
    else
        check_fail "Phase 1: artifact declares role_split_cards" \
            "no 'role_split_cards:' key in $ARTIFACT"
    fi

    if grep -q "role_split_cards: $ROLE_CARD_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 1: artifact enumerates $ROLE_CARD_COUNT role-split cards"
    else
        check_fail "Phase 1: artifact enumerates role-split cards" \
            "expected 'role_split_cards: $ROLE_CARD_COUNT' in $ARTIFACT (found $ROLE_CARD_COUNT on disk)"
    fi
else
    check_fail "Phase 1: artifact enumerates role-split cards" \
        "artifact missing — cannot verify role-split card enumeration"
fi

# ---------------------------------------------------------------------------
# (c) The inventory artifact identifies the 17 monolithic references to
#     non-existent files across the 7 audit domains.
# ---------------------------------------------------------------------------
echo "--- (c): inventory artifact identifies the 17 monolithic references ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "monolithic_references:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 1: artifact declares monolithic_references"
    else
        check_fail "Phase 1: artifact declares monolithic_references" \
            "no 'monolithic_references:' key in $ARTIFACT"
    fi

    if grep -q "total: 17" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 1: artifact identifies 17 monolithic references"
    else
        check_fail "Phase 1: artifact identifies 17 monolithic references" \
            "expected 'total: 17' in $ARTIFACT"
    fi

    for domain in coherence-maintenance concern-separation content-audit drift-detection guideline-audit test-quality-audit verification-audit; do
        if grep -q "$domain:" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 1: artifact lists monolithic domain $domain"
        else
            check_fail "Phase 1: artifact lists monolithic domain $domain" \
                "no '$domain:' entry in $ARTIFACT"
        fi
    done
else
    check_fail "Phase 1: artifact identifies 17 monolithic references" \
        "artifact missing — cannot verify monolithic reference identification"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 1 (audit role-card surface inventory) not yet"
    echo "implemented. The inventory artifact at $ARTIFACT is missing or incomplete."
    echo "GREEN produces the artifact enumerating the 48 role-split cards and the"
    echo "17 monolithic references to non-existent files."
    echo ""
    exit 1
fi
echo "Phase 1 is GREEN — the audit role-card surface inventory artifact enumerates"
echo "the role-split cards and identifies the 17 monolithic references."
echo ""
exit 0

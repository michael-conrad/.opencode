#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 4 — audit role-card cross-reference inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 4 — audit role-card cross-reference inventory (prep for SC-40),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 4 (preparation, no SC): Produce the cross-reference inventory artifact
#   mapping each monolithic reference to the actual role-split card it should
#   point to (prep for SC-40). Depends on Phase 1 (the audit role-card surface
#   inventory artifact enumerates the 48 role-split cards and the 17 monolithic
#   references to non-existent `tasks/<domain>.md` files).
#
# The cross-reference inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-cross-reference-inventory.yaml`;
#   (b) map each of the 17 monolithic references to the actual role-split card
#       it should point to. Each mapping entry SHALL record the source role card
#       (`source`), the non-existent monolithic target it currently references
#       (`monolithic_target`), and the correct role-split card on disk
#       (`correct_target`). The correct target is derived from the reference's
#       role description on disk:
#         - a reference describing the target as an "Evaluator role" SHALL point
#           to the `-evaluator.md` card for the domain;
#         - a reference describing the target as a "Main task" /
#           "orchestrator-level dispatch" SHALL point to the `-arbiter.md` card
#           for the domain.
#   (c) cover all 17 monolithic references across the 7 audit domains
#       (coherence-maintenance: 2, concern-separation: 2, content-audit: 2,
#       drift-detection: 4, guideline-audit: 2, test-quality-audit: 3,
#       verification-audit: 2).
#
# RED state: the cross-reference inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path mapping each monolithic
#   reference to the actual role-split card it should point to.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the cross-reference inventory
#   artifact. It is the RED/GREEN gate for the Phase 4 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase4-audit-role-card-cross-reference-inventory.sh
# Exit:  0 if the cross-reference inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-cross-reference-inventory.yaml"

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
echo "=== Phase 4 — audit role-card cross-reference inventory (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo "Artifact:   $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# (a) The cross-reference inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): cross-reference inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 4: cross-reference inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 4: cross-reference inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card cross-reference inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact maps each of the 17 monolithic references to the actual
#     role-split card it should point to.
#
# The expected mapping is derived from the on-disk reference role description:
#   - "Evaluator role" -> the `-evaluator.md` card for the domain
#   - "Main task" / "orchestrator-level dispatch" -> the `-arbiter.md` card
#
# Each mapping entry SHALL record `source` (the role card carrying the broken
# reference), `monolithic_target` (the non-existent `tasks/<domain>.md` file),
# and `correct_target` (the role-split card on disk).
# ---------------------------------------------------------------------------
echo "--- (b): artifact maps each monolithic reference to the correct role-split card ---"

# Format: "<source>|<correct_target>"
EXPECTED_MAPPINGS=(
    "coherence-maintenance-investigator.md|coherence-maintenance-evaluator.md"
    "coherence-maintenance-validator.md|coherence-maintenance-evaluator.md"
    "concern-separation-investigator.md|concern-separation-evaluator.md"
    "concern-separation-validator.md|concern-separation-evaluator.md"
    "content-audit-investigator.md|content-audit-evaluator.md"
    "content-audit-validator.md|content-audit-evaluator.md"
    "drift-detection-arbiter.md|drift-detection-arbiter.md"
    "drift-detection-evaluator.md|drift-detection-arbiter.md"
    "drift-detection-investigator.md|drift-detection-evaluator.md"
    "drift-detection-validator.md|drift-detection-evaluator.md"
    "guideline-audit-investigator.md|guideline-audit-evaluator.md"
    "guideline-audit-validator.md|guideline-audit-evaluator.md"
    "test-quality-audit-arbiter.md|test-quality-audit-arbiter.md"
    "test-quality-audit-investigator.md|test-quality-audit-evaluator.md"
    "test-quality-audit-validator.md|test-quality-audit-evaluator.md"
    "verification-audit-investigator.md|verification-audit-evaluator.md"
    "verification-audit-validator.md|verification-audit-evaluator.md"
)

if [ -f "$ARTIFACT" ]; then
    if grep -q "mappings:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 4: artifact declares a mappings list"
    else
        check_fail "Phase 4: artifact declares a mappings list" \
            "no 'mappings:' key in $ARTIFACT"
    fi

    for entry in "${EXPECTED_MAPPINGS[@]}"; do
        source_card="${entry%%|*}"
        correct_target="${entry##*|}"
        if grep -q "source: $source_card" "$ARTIFACT" 2>/dev/null \
            && grep -q "correct_target: $correct_target" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 4: $source_card maps to $correct_target"
        else
            check_fail "Phase 4: $source_card maps to $correct_target" \
                "artifact does not map source '$source_card' to correct_target '$correct_target'"
        fi
    done
else
    check_fail "Phase 4: artifact maps monolithic references" \
        "artifact missing — cannot verify the 17 monolithic-reference mappings"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 17 monolithic references across the 7 audit
#     domains.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 17 monolithic references across the 7 domains ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "total: 17" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 4: artifact records 17 monolithic references"
    else
        check_fail "Phase 4: artifact records 17 monolithic references" \
            "expected 'total: 17' in $ARTIFACT"
    fi

    for domain in coherence-maintenance concern-separation content-audit drift-detection guideline-audit test-quality-audit verification-audit; do
        if grep -q "$domain:" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 4: artifact covers domain $domain"
        else
            check_fail "Phase 4: artifact covers domain $domain" \
                "no '$domain:' entry in $ARTIFACT"
        fi
    done
else
    check_fail "Phase 4: artifact covers 17 monolithic references" \
        "artifact missing — cannot verify domain coverage"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 4 (audit role-card cross-reference inventory) not yet"
    echo "implemented. The cross-reference inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact mapping each of the 17 monolithic"
    echo "references to the actual role-split card it should point to."
    echo ""
    exit 1
fi
echo "Phase 4 is GREEN — the audit role-card cross-reference inventory artifact maps"
echo "each of the 17 monolithic references to the actual role-split card it should"
echo "point to."
echo ""
exit 0

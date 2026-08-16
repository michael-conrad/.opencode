#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-40 — audit monolithic task-file
# references repaired
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Target: .opencode/skills/audit/tasks/*.md
#
# SC-40: Repair the 17 monolithic task-file references in audit/tasks that
#   point to non-existent files, so each points to the actual role-split card
#   it should reference.
#
# The 17 monolithic references point to non-existent `tasks/<domain>.md` files
# (the domain was split into role cards arbiter/evaluator/investigator/
# validator). Each broken reference SHALL be repaired to point to the actual
# role-split card on disk. The correct target is derived from the reference's
# role description on disk (per the Phase 4 cross-reference inventory artifact
# `.opencode/.issues/2254/artifacts/audit-role-card-cross-reference-inventory.yaml`):
#   - a reference describing the target as an "Evaluator role" SHALL point to
#     the `-evaluator.md` card for the domain;
#   - a reference describing the target as a "Main task" /
#     "orchestrator-level dispatch" SHALL point to the `-arbiter.md` card for
#     the domain.
#
# RED state: the 17 monolithic references are still present in audit/tasks.
#   Assertions (a) and (b) FAIL because each source file still references the
#   non-existent `tasks/<domain>.md` file and does not yet reference the
#   correct role-split card.
#   GREEN repairs each reference to point to the actual role-split card.
#
# Evidence type: content-verification (structural/string). This test checks
#   the on-disk reference targets in the audit role cards. It is the RED/GREEN
#   gate for SC-40.
#
# Usage: bash .opencode/tests-v2/test-2254-sc40-audit-monolithic-references-repaired.sh
# Exit:  0 if all 17 monolithic references are repaired (GREEN),
#        1 if any reference is still broken or missing (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"

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
echo "=== SC-40 — audit monolithic task-file references repaired (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo ""

# ---------------------------------------------------------------------------
# The 17 monolithic references and their correct role-split card targets.
#
# Format: "<source_card>|<domain>|<correct_target>"
#   - source_card:     the role card carrying the broken reference
#   - domain:          the monolithic domain (the non-existent `tasks/<domain>.md`)
#   - correct_target:  the role-split card the reference SHALL point to
#
# Correct targets are derived from the Phase 4 cross-reference inventory
# artifact (`.opencode/.issues/2254/artifacts/audit-role-card-cross-reference-inventory.yaml`).
# ---------------------------------------------------------------------------
EXPECTED_MAPPINGS=(
    "coherence-maintenance-investigator.md|coherence-maintenance|coherence-maintenance-evaluator.md"
    "coherence-maintenance-validator.md|coherence-maintenance|coherence-maintenance-evaluator.md"
    "concern-separation-investigator.md|concern-separation|concern-separation-evaluator.md"
    "concern-separation-validator.md|concern-separation|concern-separation-evaluator.md"
    "content-audit-investigator.md|content-audit|content-audit-evaluator.md"
    "content-audit-validator.md|content-audit|content-audit-evaluator.md"
    "drift-detection-arbiter.md|drift-detection|drift-detection-arbiter.md"
    "drift-detection-evaluator.md|drift-detection|drift-detection-arbiter.md"
    "drift-detection-investigator.md|drift-detection|drift-detection-evaluator.md"
    "drift-detection-validator.md|drift-detection|drift-detection-evaluator.md"
    "guideline-audit-investigator.md|guideline-audit|guideline-audit-evaluator.md"
    "guideline-audit-validator.md|guideline-audit|guideline-audit-evaluator.md"
    "test-quality-audit-arbiter.md|test-quality-audit|test-quality-audit-arbiter.md"
    "test-quality-audit-investigator.md|test-quality-audit|test-quality-audit-evaluator.md"
    "test-quality-audit-validator.md|test-quality-audit|test-quality-audit-evaluator.md"
    "verification-audit-investigator.md|verification-audit|verification-audit-evaluator.md"
    "verification-audit-validator.md|verification-audit|verification-audit-evaluator.md"
)

# ---------------------------------------------------------------------------
# (a) No audit role card references a non-existent monolithic `tasks/<domain>.md`
#     file. Each of the 17 broken references SHALL be repaired.
# ---------------------------------------------------------------------------
echo "--- (a): no monolithic task-file reference points to a non-existent file ---"

for entry in "${EXPECTED_MAPPINGS[@]}"; do
    source_card="${entry%%|*}"
    rest="${entry#*|}"
    domain="${rest%%|*}"
    monolithic_target="tasks/${domain}.md"

    if [ -f "$AUDIT_DIR/$source_card" ]; then
        if grep -qF "$monolithic_target" "$AUDIT_DIR/$source_card"; then
            check_fail "SC-40: $source_card no longer references $monolithic_target" \
                "still contains the non-existent monolithic reference '$monolithic_target' (GREEN must repair it)"
        else
            check_pass "SC-40: $source_card no longer references $monolithic_target"
        fi
    else
        check_fail "SC-40: $source_card exists" \
            "missing $AUDIT_DIR/$source_card (cannot verify reference repair)"
    fi
done

# ---------------------------------------------------------------------------
# (b) Each repaired reference points to the actual role-split card on disk.
# ---------------------------------------------------------------------------
echo "--- (b): each repaired reference points to the actual role-split card ---"

for entry in "${EXPECTED_MAPPINGS[@]}"; do
    source_card="${entry%%|*}"
    rest="${entry#*|}"
    domain="${rest%%|*}"
    correct_target="${rest#*|}"
    correct_ref="tasks/${correct_target}"

    if [ -f "$AUDIT_DIR/$source_card" ]; then
        if grep -qF "$correct_ref" "$AUDIT_DIR/$source_card"; then
            check_pass "SC-40: $source_card references $correct_ref"
        else
            check_fail "SC-40: $source_card references $correct_ref" \
                "does not reference the correct role-split card '$correct_ref' (GREEN must repoint it)"
        fi
    else
        check_fail "SC-40: $source_card exists" \
            "missing $AUDIT_DIR/$source_card (cannot verify correct reference)"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-40 (audit monolithic task-file references repaired)"
    echo "not yet implemented. The 17 monolithic references in audit/tasks still point"
    echo "to non-existent 'tasks/<domain>.md' files. GREEN repairs each reference to"
    echo "point to the actual role-split card it should reference."
    echo ""
    exit 1
fi
echo "SC-40 is GREEN — all 17 monolithic task-file references in audit/tasks point"
echo "to the actual role-split card they should reference."
echo ""
exit 0

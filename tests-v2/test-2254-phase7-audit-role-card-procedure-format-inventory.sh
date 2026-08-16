#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 7 — audit role-card Procedure format inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 7 — audit role-card Procedure format audit (prep for SC-25),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 7 (preparation, no SC): Produce the Procedure-format inventory artifact
#   identifying task cards whose Procedure sections use plain numbered lists
#   instead of numbered-checkbox (prep for SC-25). Depends on Phase 1 (the audit
#   role-card surface inventory artifact enumerates the 48 role-split cards).
#
# The Procedure-format inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-procedure-format-inventory.yaml`;
#   (b) enumerate each of the 48 audit role cards' Procedure format. Each entry
#       SHALL record the role card (`card`) and its Procedure format
#       (`procedure_format`), matching the on-disk Procedure section of the card
#       (the `## Procedure` section). A card whose Procedure section contains a
#       plain numbered list item (`N. ` at line start) SHALL be inventoried as
#       `plain-numbered-list`; a card whose Procedure section uses only
#       numbered-checkbox markers (`- [ ] N.`) SHALL be inventoried as
#       `numbered-checkbox`.
#   (c) cover all 48 audit role cards (`role_split_cards: 48`).
#
# RED state: the Procedure-format inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating each role
#   card's Procedure format.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the Procedure-format inventory
#   artifact. It is the RED/GREEN gate for the Phase 7 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase7-audit-role-card-procedure-format-inventory.sh
# Exit:  0 if the Procedure-format inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-procedure-format-inventory.yaml"

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

# Classify the Procedure format of a role card directly from its on-disk
# `## Procedure` section, independent of the artifact. A card whose Procedure
# section contains a plain numbered list item (`N. ` at line start) is
# `plain-numbered-list`; otherwise it is `numbered-checkbox`.
on_disk_format() {
    local f="$1"
    local section
    section="$(awk '/^## Procedure/{flag=1; next} /^## /{if (flag) exit} flag' "$f")"
    if echo "$section" | grep -qE '^[[:space:]]*[0-9]+\. '; then
        printf 'plain-numbered-list'
    else
        printf 'numbered-checkbox'
    fi
}

# Extract the procedure_format value for a given role card from the artifact.
artifact_format() {
    local card="$1"
    awk -v c="$card" '
        $0 ~ "^  - card: " c { in_card=1; next }
        in_card && /^    procedure_format:/ {
            line=$0
            sub(/^[[:space:]]*procedure_format:[[:space:]]*/, "", line)
            print line
            in_card=0
        }
    ' "$ARTIFACT"
}

echo ""
echo "=== Phase 7 — audit role-card Procedure format inventory (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo "Artifact:   $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference: the 48 audit role-split cards (arbiter/evaluator/
# investigator/validator suffixes), independent of the artifact.
# ---------------------------------------------------------------------------
ROLE_CARDS=()
for f in "$AUDIT_DIR"/*.md; do
    base="$(basename "$f")"
    for suffix in arbiter evaluator investigator validator; do
        if [[ "$base" == *"-$suffix.md" ]]; then
            ROLE_CARDS+=("$base")
            break
        fi
    done
done
ROLE_COUNT="${#ROLE_CARDS[@]}"

echo "On-disk: $ROLE_COUNT audit role-split cards (arbiter/evaluator/investigator/validator)."
echo ""

# ---------------------------------------------------------------------------
# (a) The Procedure-format inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): Procedure-format inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 7: Procedure-format inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 7: Procedure-format inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card Procedure-format inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact enumerates each role card's Procedure format, matching the
#     on-disk Procedure section.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates each role card's Procedure format ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "procedure_formats:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 7: artifact declares a procedure_formats list"
    else
        check_fail "Phase 7: artifact declares a procedure_formats list" \
            "no 'procedure_formats:' key in $ARTIFACT"
    fi

    for card in "${ROLE_CARDS[@]}"; do
        expected="$(on_disk_format "$AUDIT_DIR/$card")"
        if grep -q "card: $card" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 7: artifact inventories role card $card"
        else
            check_fail "Phase 7: artifact inventories role card $card" \
                "no 'card: $card' entry in $ARTIFACT"
            continue
        fi
        actual="$(artifact_format "$card")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 7: $card procedure_format matches on-disk ($expected)"
        else
            check_fail "Phase 7: $card procedure_format matches on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 7: artifact enumerates role card Procedure format" \
        "artifact missing — cannot verify the $ROLE_COUNT role cards' Procedure format"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 48 audit role cards.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 48 audit role cards ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_cards: $ROLE_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 7: artifact records $ROLE_COUNT role cards"
    else
        check_fail "Phase 7: artifact records $ROLE_COUNT role cards" \
            "expected 'role_split_cards: $ROLE_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 7: artifact covers all 48 role cards" \
        "artifact missing — cannot verify role-card coverage"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 7 (audit role-card Procedure format inventory) not yet"
    echo "implemented. The Procedure-format inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating each of the $ROLE_COUNT"
    echo "audit role cards' Procedure format (numbered-checkbox vs plain-numbered-list)."
    echo ""
    exit 1
fi
echo "Phase 7 is GREEN — the audit role-card Procedure-format inventory artifact"
echo "enumerates each of the $ROLE_COUNT role cards' Procedure format."
echo ""
exit 0

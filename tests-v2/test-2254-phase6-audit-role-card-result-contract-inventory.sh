#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 6 — audit role-card result contract inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 6 — audit role-card result contract inventory (prep for SC-42),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 6 (preparation, no SC): Produce the result-contract inventory artifact
#   enumerating each role card's Result Contract field names (e.g., `summary`)
#   (prep for SC-42). Depends on Phase 1 (the audit role-card surface inventory
#   artifact enumerates the 48 role-split cards).
#
# The result-contract inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-result-contract-inventory.yaml`;
#   (b) enumerate each of the 48 audit role cards' Result Contract field names.
#       Each entry SHALL record the role card (`card`) and the set of field names
#       it returns (`field_names`), matching the on-disk Result Contract yaml
#       block of the card (the `## Result Contract`, `## Output`, or
#       `Return Frugal Result Contract` step). A role card with no Result
#       Contract block SHALL be inventoried with an empty `field_names` set.
#   (c) cover all 48 audit role cards (`role_split_cards: 48`).
#
# RED state: the result-contract inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating each role
#   card's Result Contract field names.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the result-contract inventory
#   artifact. It is the RED/GREEN gate for the Phase 6 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase6-audit-role-card-result-contract-inventory.sh
# Exit:  0 if the result-contract inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-result-contract-inventory.yaml"

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

# Extract the Result Contract field names of a role card directly from its
# on-disk Result Contract yaml block (the `## Result Contract`, `## Output`,
# or `Return Frugal Result Contract` step), independent of the artifact.
# Returns the field names sorted, space-separated. A card with no Result
# Contract block returns an empty string.
on_disk_fields() {
    local f="$1"
    local result
    result="$(awk '
        /Return Frugal Result Contract|^## Result Contract|^## Output/ { in_rc=1 }
        in_rc && /```/ {
            if (in_yaml) { exit }
            in_yaml=1
            next
        }
        in_rc && in_yaml {
            line=$0
            sub(/^[[:space:]]+/, "", line)
            if (line ~ /^[a-z_]+:/) { sub(/:.*$/, "", line); print line }
        }
    ' "$f" | sort -u | tr '\n' ' ' | sed 's/ $//')" || true
    printf '%s' "$result"
}

# Extract the field_names list for a given role card from the artifact.
# Returns the field names sorted, space-separated.
artifact_fields() {
    local card="$1"
    awk -v c="$card" '
        $0 ~ "^  - card: " c { in_card=1; next }
        in_card && /^    field_names:/ {
            line=$0
            sub(/^    field_names:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            gsub(/,/, " ", line)
            gsub(/[[:space:]]+/, " ", line)
            print line
            in_card=0
        }
    ' "$ARTIFACT" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

echo ""
echo "=== Phase 6 — audit role-card result contract inventory (Spec .opencode#2254) ==="
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
# (a) The result-contract inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): result-contract inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 6: result-contract inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 6: result-contract inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card result-contract inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact enumerates each role card's Result Contract field names,
#     matching the on-disk Result Contract yaml block.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates each role card's Result Contract field names ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "result_contracts:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 6: artifact declares a result_contracts list"
    else
        check_fail "Phase 6: artifact declares a result_contracts list" \
            "no 'result_contracts:' key in $ARTIFACT"
    fi

    for card in "${ROLE_CARDS[@]}"; do
        expected="$(on_disk_fields "$AUDIT_DIR/$card")"
        if grep -q "card: $card" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 6: artifact inventories role card $card"
        else
            check_fail "Phase 6: artifact inventories role card $card" \
                "no 'card: $card' entry in $ARTIFACT"
            continue
        fi
        actual="$(artifact_fields "$card")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 6: $card field_names match on-disk ($expected)"
        else
            check_fail "Phase 6: $card field_names match on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 6: artifact enumerates role card Result Contract field names" \
        "artifact missing — cannot verify the $ROLE_COUNT role cards' Result Contract field names"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 48 audit role cards.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 48 audit role cards ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_cards: $ROLE_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 6: artifact records $ROLE_COUNT role cards"
    else
        check_fail "Phase 6: artifact records $ROLE_COUNT role cards" \
            "expected 'role_split_cards: $ROLE_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 6: artifact covers all 48 role cards" \
        "artifact missing — cannot verify role-card coverage"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 6 (audit role-card result contract inventory) not yet"
    echo "implemented. The result-contract inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating each of the $ROLE_COUNT"
    echo "audit role cards' Result Contract field names."
    echo ""
    exit 1
fi
echo "Phase 6 is GREEN — the audit role-card result-contract inventory artifact"
echo "enumerates each of the $ROLE_COUNT role cards' Result Contract field names."
echo ""
exit 0

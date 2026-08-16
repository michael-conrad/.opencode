#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 5 — audit role-card dispatch contract inventory
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 5 — audit role-card dispatch contract inventory (prep for SC-41),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 5 (preparation, no SC): Produce the dispatch-contract inventory artifact
#   enumerating each role card's accepted Dispatch Contract params (prep for
#   SC-41). Depends on Phase 1 (the audit role-card surface inventory artifact
#   enumerates the 48 role-split cards).
#
# The dispatch-contract inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-dispatch-contract-inventory.yaml`;
#   (b) enumerate each of the 48 audit role cards' accepted Dispatch Contract
#       params. Each entry SHALL record the role card (`card`) and the set of
#       params it accepts (`accepted_params`), matching the on-disk `## Dispatch
#       Contract` section of the card. A role card with no `## Dispatch Contract`
#       section SHALL be inventoried with an empty `accepted_params` set.
#   (c) cover all 48 audit role cards (`role_split_cards: 48`).
#
# RED state: the dispatch-contract inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating each role
#   card's accepted Dispatch Contract params.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the dispatch-contract inventory
#   artifact. It is the RED/GREEN gate for the Phase 5 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase5-audit-role-card-dispatch-contract-inventory.sh
# Exit:  0 if the dispatch-contract inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-dispatch-contract-inventory.yaml"

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

# Extract the accepted Dispatch Contract params of a role card directly from
# its on-disk `## Dispatch Contract` section (live, independent of the
# artifact). Returns the params sorted, space-separated. A card with no
# `## Dispatch Contract` section returns an empty string.
on_disk_params() {
    local f="$1"
    local result
    result="$(awk '/^## Dispatch Contract/{f=1;next} /^## /{f=0} f' "$f" \
        | grep -oE '^- `[a-z_.]+`' \
        | sed 's/^- `//; s/`$//' \
        | sort | tr '\n' ' ' | sed 's/ $//')" || true
    printf '%s' "$result"
}

# Extract the accepted_params list for a given role card from the artifact.
# Returns the params sorted, space-separated.
artifact_params() {
    local card="$1"
    awk -v c="$card" '
        $0 ~ "^  - card: " c { in_card=1; next }
        in_card && /^    accepted_params:/ {
            line=$0
            sub(/^    accepted_params:[[:space:]]*\[/, "", line)
            sub(/\].*$/, "", line)
            gsub(/,/, " ", line)
            gsub(/[[:space:]]+/, " ", line)
            print line
            in_card=0
        }
    ' "$ARTIFACT" | tr ' ' '\n' | sed '/^$/d' | sort | tr '\n' ' ' | sed 's/ $//'
}

echo ""
echo "=== Phase 5 — audit role-card dispatch contract inventory (Spec .opencode#2254) ==="
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
# (a) The dispatch-contract inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): dispatch-contract inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 5: dispatch-contract inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 5: dispatch-contract inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card dispatch-contract inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact enumerates each role card's accepted Dispatch Contract
#     params, matching the on-disk `## Dispatch Contract` section.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates each role card's accepted Dispatch Contract params ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "dispatch_contracts:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 5: artifact declares a dispatch_contracts list"
    else
        check_fail "Phase 5: artifact declares a dispatch_contracts list" \
            "no 'dispatch_contracts:' key in $ARTIFACT"
    fi

    for card in "${ROLE_CARDS[@]}"; do
        expected="$(on_disk_params "$AUDIT_DIR/$card")"
        if grep -q "card: $card" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 5: artifact inventories role card $card"
        else
            check_fail "Phase 5: artifact inventories role card $card" \
                "no 'card: $card' entry in $ARTIFACT"
            continue
        fi
        actual="$(artifact_params "$card")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 5: $card accepted_params match on-disk ($expected)"
        else
            check_fail "Phase 5: $card accepted_params match on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 5: artifact enumerates role card accepted params" \
        "artifact missing — cannot verify the $ROLE_COUNT role cards' accepted Dispatch Contract params"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 48 audit role cards.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 48 audit role cards ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_cards: $ROLE_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 5: artifact records $ROLE_COUNT role cards"
    else
        check_fail "Phase 5: artifact records $ROLE_COUNT role cards" \
            "expected 'role_split_cards: $ROLE_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 5: artifact covers all 48 role cards" \
        "artifact missing — cannot verify role-card coverage"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 5 (audit role-card dispatch contract inventory) not yet"
    echo "implemented. The dispatch-contract inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating each of the $ROLE_COUNT"
    echo "audit role cards' accepted Dispatch Contract params."
    echo ""
    exit 1
fi
echo "Phase 5 is GREEN — the audit role-card dispatch-contract inventory artifact"
echo "enumerates each of the $ROLE_COUNT role cards' accepted Dispatch Contract params."
echo ""
exit 0

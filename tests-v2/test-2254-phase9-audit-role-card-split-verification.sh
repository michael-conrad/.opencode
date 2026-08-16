#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 9 — audit role-card split verification
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 9 — audit role-card split verification (prep),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 9 (preparation, no SC): Produce the split verification artifact
#   confirming the role cards are organized as role-split cards
#   (investigator/validator/evaluator/arbiter) (prep). Depends on Phase 1
#   (the audit role-card surface inventory artifact enumerates the 48
#   role-split cards).
#
# The split verification artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-split-verification.yaml`;
#   (b) confirm the role cards are organized as role-split cards by declaring
#       the four role suffixes (`role_split_card_suffixes`) and enumerating
#       each of the 48 audit role cards (`role_split_cards_list`), where each
#       enumerated card's role suffix matches the on-disk filename;
#   (c) cover all 48 audit role cards (`role_split_cards: 48`).
#
# RED state: the split verification artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path confirming the role cards
#   are organized as role-split cards (investigator/validator/evaluator/arbiter).
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the split verification artifact.
#   It is the RED/GREEN gate for the Phase 9 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase9-audit-role-card-split-verification.sh
# Exit:  0 if the split verification artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-split-verification.yaml"

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

# Determine the role suffix (arbiter/evaluator/investigator/validator) of a
# role card filename, independent of the artifact. Returns empty if the file
# does not carry a role suffix.
on_disk_role_suffix() {
    local base="$1"
    for suffix in arbiter evaluator investigator validator; do
        if [[ "$base" == *"-$suffix.md" ]]; then
            printf '%s' "$suffix"
            return
        fi
    done
    printf ''
}

# Extract the role suffix recorded for a given role card in the artifact.
artifact_role_suffix() {
    local card="$1"
    awk -v c="$card" '
        $0 ~ "^  - name: " c "$" { in_card=1; next }
        in_card && /^    role:/ {
            line=$0
            sub(/^[[:space:]]*role:[[:space:]]*/, "", line)
            print line
            in_card=0
        }
    ' "$ARTIFACT"
}

echo ""
echo "=== Phase 9 — audit role-card split verification (Spec .opencode#2254) ==="
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
# (a) The split verification artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): split verification artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 9: split verification artifact exists at $ARTIFACT"
else
    check_fail "Phase 9: split verification artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card split verification artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact confirms the role cards are role-split: declares the four
#     role suffixes and enumerates each role card with a matching role suffix.
# ---------------------------------------------------------------------------
echo "--- (b): artifact confirms role cards are role-split (investigator/validator/evaluator/arbiter) ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_card_suffixes:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 9: artifact declares role_split_card_suffixes"
    else
        check_fail "Phase 9: artifact declares role_split_card_suffixes" \
            "no 'role_split_card_suffixes:' key in $ARTIFACT"
    fi

    for suffix in arbiter evaluator investigator validator; do
        if grep -q "^- $suffix$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 9: artifact lists role suffix '$suffix'"
        else
            check_fail "Phase 9: artifact lists role suffix '$suffix'" \
                "no '- $suffix' entry under role_split_card_suffixes in $ARTIFACT"
        fi
    done

    for card in "${ROLE_CARDS[@]}"; do
        expected="$(on_disk_role_suffix "$card")"
        if grep -q "^  - name: $card$" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 9: artifact enumerates role card $card"
        else
            check_fail "Phase 9: artifact enumerates role card $card" \
                "no '  - name: $card' entry in role_split_cards_list in $ARTIFACT"
            continue
        fi
        actual="$(artifact_role_suffix "$card")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 9: $card role suffix matches on-disk ($expected)"
        else
            check_fail "Phase 9: $card role suffix matches on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 9: artifact confirms role cards are role-split" \
        "artifact missing — cannot verify the $ROLE_COUNT role cards are organized as role-split cards"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 48 audit role cards.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 48 audit role cards ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_cards: $ROLE_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 9: artifact records $ROLE_COUNT role cards"
    else
        check_fail "Phase 9: artifact records $ROLE_COUNT role cards" \
            "expected 'role_split_cards: $ROLE_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 9: artifact covers all 48 role cards" \
        "artifact missing — cannot verify role-card coverage"
fi

# ---------------------------------------------------------------------------
# (d) The artifact parses as valid YAML. Defect guard: role_split_cards_list
#     must be well-formed YAML mappings (each item a {name, role} mapping),
#     not scalar items mixed with mapping keys at the same indentation. This
#     assertion uses a real YAML parser so this defect class cannot recur.
# ---------------------------------------------------------------------------
echo "--- (d): artifact parses as valid YAML ---"

if [ -f "$ARTIFACT" ]; then
    if python3 -c "
import sys, yaml
try:
    with open('$ARTIFACT') as f:
        data = yaml.safe_load(f)
except Exception as e:
    print('YAML parse error: %s' % e, file=sys.stderr)
    sys.exit(1)
if not isinstance(data, dict):
    print('YAML root is not a mapping', file=sys.stderr)
    sys.exit(1)
lst = data.get('role_split_cards_list')
if not isinstance(lst, list):
    print('role_split_cards_list is not a list', file=sys.stderr)
    sys.exit(1)
for item in lst:
    if not isinstance(item, dict) or 'name' not in item or 'role' not in item:
        print('role_split_cards_list item is not a {name, role} mapping: %r' % (item,), file=sys.stderr)
        sys.exit(1)
sys.exit(0)
"; then
        check_pass "Phase 9: artifact parses as valid YAML (role_split_cards_list is well-formed {name, role} mappings)"
    else
        check_fail "Phase 9: artifact parses as valid YAML" \
            "artifact is not valid YAML — role_split_cards_list must be well-formed {name, role} mappings (see stderr)"
    fi
else
    check_fail "Phase 9: artifact parses as valid YAML" \
        "artifact missing — cannot validate YAML"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 9 (audit role-card split verification) not yet"
    echo "implemented. The split verification artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact confirming the $ROLE_COUNT"
    echo "audit role cards are organized as role-split cards"
    echo "(investigator/validator/evaluator/arbiter)."
    echo ""
    exit 1
fi
echo "Phase 9 is GREEN — the audit role-card split verification artifact"
echo "confirms the $ROLE_COUNT role cards are organized as role-split cards"
echo "(investigator/validator/evaluator/arbiter)."
echo ""
exit 0

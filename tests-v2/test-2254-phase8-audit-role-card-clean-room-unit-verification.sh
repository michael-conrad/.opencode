#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 8 — audit role-card clean-room unit verification
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 8 — audit role-card clean-room unit verification (prep),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 8 (preparation, no SC): Produce the clean-room unit verification artifact
#   confirming no role card dispatches sub-agents internally (prep). Depends on
#   Phase 1 (the audit role-card surface inventory artifact enumerates the 48
#   role-split cards).
#
# Per the plan's Execution Model, sub-agents CANNOT dispatch sub-agents
# (`task: deny` is hardcoded). A role card's Procedure SHALL NOT require the
# role sub-agent to dispatch another sub-agent internally. The clean-room unit
# verification artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-clean-room-unit-verification.yaml`;
#   (b) enumerate each of the 48 audit role cards. Each entry SHALL record the
#       role card (`card`) and whether its Procedure requires internal
#       sub-agent dispatch (`internal_subagent_dispatch`), matching the on-disk
#       `## Procedure` section of the card. A card whose Procedure contains an
#       imperative internal sub-agent dispatch instruction (a `task()` call
#       dispatching another sub-agent, or an imperative "dispatch a sub-agent" /
#       "dispatch another sub-agent" directive) SHALL be inventoried as `true`;
#       a card whose Procedure contains no such imperative instruction SHALL be
#       inventoried as `false`.
#   (c) cover all 48 audit role cards (`role_split_cards: 48`).
#
# RED state: the clean-room unit verification artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the artifact at the declared path enumerating each role
#   card's internal-sub-agent-dispatch status.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the clean-room unit verification
#   artifact. It is the RED/GREEN gate for the Phase 8 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase8-audit-role-card-clean-room-unit-verification.sh
# Exit:  0 if the clean-room unit verification artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-clean-room-unit-verification.yaml"

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

# Classify whether a role card's `## Procedure` section requires internal
# sub-agent dispatch, independent of the artifact. An imperative internal
# sub-agent dispatch instruction is a `task()` call dispatching another
# sub-agent, or an imperative "dispatch a sub-agent" / "dispatch another
# sub-agent" directive within the Procedure. Descriptive references to the
# "dispatch contract" (the parameters passed to this sub-agent) and to the
# orchestrator dispatching the role are NOT internal sub-agent dispatch.
on_disk_internal_dispatch() {
    local f="$1"
    local section
    section="$(awk '/^## Procedure/{flag=1; next} /^## /{if (flag) exit} flag' "$f")"
    if echo "$section" | grep -qE 'task\(subagent|call task\(|task\(\)|dispatch a sub-agent|dispatch another sub-agent'; then
        printf 'true'
    else
        printf 'false'
    fi
}

# Extract the internal_subagent_dispatch value for a given role card from the artifact.
artifact_dispatch() {
    local card="$1"
    awk -v c="$card" '
        $0 ~ "^  - card: " c { in_card=1; next }
        in_card && /^    internal_subagent_dispatch:/ {
            line=$0
            sub(/^[[:space:]]*internal_subagent_dispatch:[[:space:]]*/, "", line)
            print line
            in_card=0
        }
    ' "$ARTIFACT"
}

echo ""
echo "=== Phase 8 — audit role-card clean-room unit verification (Spec .opencode#2254) ==="
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
# (a) The clean-room unit verification artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): clean-room unit verification artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 8: clean-room unit verification artifact exists at $ARTIFACT"
else
    check_fail "Phase 8: clean-room unit verification artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card clean-room unit verification artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The artifact enumerates each role card's internal-subagent-dispatch
#     status, matching the on-disk Procedure section.
# ---------------------------------------------------------------------------
echo "--- (b): artifact enumerates each role card's internal-subagent-dispatch status ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "clean_room_unit_verifications:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 8: artifact declares a clean_room_unit_verifications list"
    else
        check_fail "Phase 8: artifact declares a clean_room_unit_verifications list" \
            "no 'clean_room_unit_verifications:' key in $ARTIFACT"
    fi

    for card in "${ROLE_CARDS[@]}"; do
        expected="$(on_disk_internal_dispatch "$AUDIT_DIR/$card")"
        if grep -q "card: $card" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 8: artifact inventories role card $card"
        else
            check_fail "Phase 8: artifact inventories role card $card" \
                "no 'card: $card' entry in $ARTIFACT"
            continue
        fi
        actual="$(artifact_dispatch "$card")"
        if [ "$actual" = "$expected" ]; then
            check_pass "Phase 8: $card internal_subagent_dispatch matches on-disk ($expected)"
        else
            check_fail "Phase 8: $card internal_subagent_dispatch matches on-disk" \
                "expected '$expected', artifact has '$actual'"
        fi
    done
else
    check_fail "Phase 8: artifact enumerates role card internal-subagent-dispatch status" \
        "artifact missing — cannot verify the $ROLE_COUNT role cards' internal-subagent-dispatch status"
fi

# ---------------------------------------------------------------------------
# (c) The artifact covers all 48 audit role cards.
# ---------------------------------------------------------------------------
echo "--- (c): artifact covers all 48 audit role cards ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "role_split_cards: $ROLE_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 8: artifact records $ROLE_COUNT role cards"
    else
        check_fail "Phase 8: artifact records $ROLE_COUNT role cards" \
            "expected 'role_split_cards: $ROLE_COUNT' in $ARTIFACT"
    fi
else
    check_fail "Phase 8: artifact covers all 48 role cards" \
        "artifact missing — cannot verify role-card coverage"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 8 (audit role-card clean-room unit verification) not yet"
    echo "implemented. The clean-room unit verification artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact enumerating each of the $ROLE_COUNT"
    echo "audit role cards' internal-subagent-dispatch status (true/false)."
    echo ""
    exit 1
fi
echo "Phase 8 is GREEN — the audit role-card clean-room unit verification artifact"
echo "enumerates each of the $ROLE_COUNT role cards' internal-subagent-dispatch status."
echo ""
exit 0

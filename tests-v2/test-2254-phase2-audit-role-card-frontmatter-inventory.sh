#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: Phase 2 — audit role-card frontmatter audit
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan.md Phase 2 — audit role-card frontmatter audit (prep for SC-43),
#        target `.opencode/skills/audit/tasks/*.md`.
#
# Phase 2 (preparation, no SC): Produce the audit role-card frontmatter
#   inventory artifact. SC-43 removed the YAML frontmatter from all 48 audit
#   role cards, so the accurate post-SC-43 on-disk state is ZERO cards carrying
#   YAML frontmatter (first line `---`) and all 50 cards (48 role cards plus
#   `completion.md`, `pr-body-audit.md`) carrying none. Depends on Phase 1 (the
#   audit role-card surface inventory artifact exists).
#
# The frontmatter inventory artifact SHALL:
#   (a) exist at `.opencode/.issues/2254/artifacts/audit-role-card-frontmatter-inventory.yaml`;
#   (b) record `frontmatter_cards: 0` — no audit role card carries YAML
#       frontmatter, matching the on-disk count of files whose first line is
#       `---`;
#   (c) record `non_frontmatter_cards: 50` — all 50 cards (48 role cards plus
#       `completion.md`, `pr-body-audit.md`) carry no YAML frontmatter.
#
# RED state: the frontmatter inventory artifact does not exist yet.
#   Assertions (a), (b), and (c) FAIL because the artifact file is absent.
#   GREEN produces the frontmatter inventory artifact at the declared path
#   with the accurate post-SC-43 frontmatter-card count and the
#   non-frontmatter card list.
#
# Evidence type: preparation phase (no SC). This content-verification test
#   checks the existence and completeness of the frontmatter inventory
#   artifact. It is the RED/GREEN gate for the Phase 2 inventory deliverable.
#
# Usage: bash .opencode/tests-v2/test-2254-phase2-audit-role-card-frontmatter-inventory.sh
# Exit:  0 if the frontmatter inventory artifact is complete (GREEN),
#        1 if it is missing or incomplete (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

AUDIT_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
ARTIFACT="$PROJECT_DIR/.opencode/.issues/2254/artifacts/audit-role-card-frontmatter-inventory.yaml"

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
echo "=== Phase 2 — audit role-card frontmatter audit (Spec .opencode#2254) ==="
echo ""
echo "Target dir: $AUDIT_DIR"
echo "Artifact:   $ARTIFACT"
echo ""

# ---------------------------------------------------------------------------
# On-disk reference counts (live, independent of the artifact).
# ---------------------------------------------------------------------------
FRONTMATTER_COUNT=$(grep -lE '^---$' "$AUDIT_DIR"/*.md 2>/dev/null | wc -l || true)
NON_FRONTMATTER_COUNT=$(for f in "$AUDIT_DIR"/*.md; do
    first=$(head -1 "$f")
    if [ "$first" != "---" ]; then
        basename "$f"
    fi
done | wc -l)

echo "On-disk: $FRONTMATTER_COUNT cards start with '---' (carry YAML frontmatter);"
echo "         $NON_FRONTMATTER_COUNT cards do not."
echo ""

# ---------------------------------------------------------------------------
# (a) The frontmatter inventory artifact exists at the declared path.
# ---------------------------------------------------------------------------
echo "--- (a): frontmatter inventory artifact exists ---"

if [ -f "$ARTIFACT" ]; then
    check_pass "Phase 2: frontmatter inventory artifact exists at $ARTIFACT"
else
    check_fail "Phase 2: frontmatter inventory artifact exists" \
        "missing $ARTIFACT (GREEN must produce the audit role-card frontmatter inventory artifact)"
fi

# ---------------------------------------------------------------------------
# (b) The frontmatter inventory artifact records `frontmatter_cards: 0` — no
#     audit role card carries YAML frontmatter (SC-43 removed it from all 48).
# ---------------------------------------------------------------------------
echo "--- (b): frontmatter inventory artifact records the frontmatter card count ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "frontmatter_cards:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 2: artifact declares frontmatter_cards"
    else
        check_fail "Phase 2: artifact declares frontmatter_cards" \
            "no 'frontmatter_cards:' key in $ARTIFACT"
    fi

    if grep -q "frontmatter_cards: $FRONTMATTER_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 2: artifact records $FRONTMATTER_COUNT frontmatter cards"
    else
        check_fail "Phase 2: artifact records frontmatter cards" \
            "expected 'frontmatter_cards: $FRONTMATTER_COUNT' in $ARTIFACT (found $FRONTMATTER_COUNT on disk)"
    fi
else
    check_fail "Phase 2: artifact records frontmatter cards" \
        "artifact missing — cannot verify frontmatter card count"
fi

# ---------------------------------------------------------------------------
# (c) The frontmatter inventory artifact records `non_frontmatter_cards: 50` —
#     all 50 cards (48 role cards plus `completion.md`, `pr-body-audit.md`)
#     carry no YAML frontmatter.
# ---------------------------------------------------------------------------
echo "--- (c): frontmatter inventory artifact records the non-frontmatter card count ---"

if [ -f "$ARTIFACT" ]; then
    if grep -q "non_frontmatter_cards:" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 2: artifact declares non_frontmatter_cards"
    else
        check_fail "Phase 2: artifact declares non_frontmatter_cards" \
            "no 'non_frontmatter_cards:' key in $ARTIFACT"
    fi

    if grep -q "non_frontmatter_cards: $NON_FRONTMATTER_COUNT" "$ARTIFACT" 2>/dev/null; then
        check_pass "Phase 2: artifact records $NON_FRONTMATTER_COUNT non-frontmatter cards"
    else
        check_fail "Phase 2: artifact records non-frontmatter cards" \
            "expected 'non_frontmatter_cards: $NON_FRONTMATTER_COUNT' in $ARTIFACT (found $NON_FRONTMATTER_COUNT on disk)"
    fi

    for card in completion pr-body-audit; do
        if grep -q "$card.md" "$ARTIFACT" 2>/dev/null; then
            check_pass "Phase 2: artifact lists non-frontmatter card $card.md"
        else
            check_fail "Phase 2: artifact lists non-frontmatter card $card.md" \
                "no '$card.md' entry in $ARTIFACT"
        fi
    done
else
    check_fail "Phase 2: artifact records non-frontmatter cards" \
        "artifact missing — cannot verify non-frontmatter card count"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: Phase 2 (audit role-card frontmatter audit) not yet"
    echo "implemented. The frontmatter inventory artifact at $ARTIFACT is missing"
    echo "or incomplete. GREEN produces the artifact recording the accurate"
    echo "post-SC-43 state: $FRONTMATTER_COUNT audit role cards carry YAML"
    echo "frontmatter and $NON_FRONTMATTER_COUNT cards (48 role cards plus"
    echo "completion.md, pr-body-audit.md) carry none."
    echo ""
    exit 1
fi
echo "Phase 2 is GREEN — the audit role-card frontmatter inventory artifact"
echo "records the accurate post-SC-43 state: $FRONTMATTER_COUNT frontmatter cards"
echo "and $NON_FRONTMATTER_COUNT non-frontmatter cards."
echo ""
exit 0

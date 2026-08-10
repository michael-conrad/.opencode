#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-15 — evidence-type taxonomy
# citations consolidated to the single canonical reference, loaded dynamically.
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-16-taxonomy-source-consolidation — SC-15 (string),
#        `.opencode/skills/spec-creation/tasks/validate.md`,
#        `.opencode/skills/audit/tasks/*.md` (role cards),
#        `.opencode/reference/cost-model-standards.md`.
#
# SC-15 (string): Evidence-type taxonomy citations in spec-creation validate and
#   audit role cards SHALL point at the single canonical reference document,
#   loaded dynamically.
#
# RED state: spec-creation/tasks/validate.md hardcodes the evidence-type-to-
#   method lookup table inline instead of citing the canonical reference, and
#   the audit role cards cite the evidence-type taxonomy from redirect sources:
#   12 role cards link `Read [Evidence Type Taxonomy](guidelines/080-code-
#   standards.md)` (redirect to a guideline), spec-audit-evaluator.md cites
#   `spec-structure-standards.md §Evidence Type Taxonomy` (redirect to a
#   different reference), and the guideline-audit role cards cite
#   `080-code-standards.md` for "evidence type taxonomy". The assertions below
#   FAIL on this content. GREEN points every taxonomy citation at the single
#   canonical reference `reference/cost-model-standards.md` (its "Tiered Cost
#   Table by Evidence Type" lists all four evidence types), loaded dynamically
#   by both validate and audit.
#
# Evidence type: SC-15 is a `string` SC. This content-verification test greps
#   spec-creation/tasks/validate.md and the audit role cards for the canonical
#   reference citation and the absence of the redirect-source citations. It is
#   the primary gate for this content-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc15-taxonomy-source.sh
# Exit:  0 if validate.md and all audit role cards cite the canonical reference
#         and zero redirect-source taxonomy citations remain (GREEN),
#        1 otherwise (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

VALIDATE_FILE="$PROJECT_DIR/.opencode/skills/spec-creation/tasks/validate.md"
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
echo "=== SC-15 — evidence-type taxonomy citations consolidated to single canonical reference (Spec .opencode#2254) ==="
echo ""
echo "Target: $VALIDATE_FILE"
echo "Audit dir: $AUDIT_DIR"
echo ""

# ---------------------------------------------------------------------------
# RED-state assertions (each FAILs on current content; GREEN reverses them).
# ---------------------------------------------------------------------------

# --- RED 1: validate.md cites the canonical reference ---
if [ -f "$VALIDATE_FILE" ]; then
    if grep -q "cost-model-standards" "$VALIDATE_FILE"; then
        check_pass "SC-15: validate.md cites the canonical reference"
    else
        check_fail "SC-15: validate.md cites the canonical reference" \
            "spec-creation/tasks/validate.md does not reference cost-model-standards.md"
    fi
else
    check_fail "SC-15: validate.md exists" "spec-creation/tasks/validate.md not found"
fi

# --- RED 2: validate.md no longer hardcodes the evidence-type lookup table ---
# RED-state: the inline Evidence Type | Required Verification Method table
# (lines ~82-87) is present. GREEN replaces the inline table with a dynamic
# citation to the canonical reference.
if [ -f "$VALIDATE_FILE" ]; then
    if grep -q "Evidence Type | Required Verification Method" "$VALIDATE_FILE"; then
        check_fail "SC-15: validate.md does not hardcode the evidence-type table" \
            "spec-creation/tasks/validate.md still contains the inline lookup table"
    else
        check_pass "SC-15: validate.md does not hardcode the evidence-type table"
    fi
fi

# ---------------------------------------------------------------------------
# Role-card taxonomy citations.
#
# The audit role cards are the *.md files in skills/audit/tasks/, excluding
# completion.md (a routing card) and pr-body-audit.md (a standalone card) which
# do not audit evidence types. We scan only role cards.
# ---------------------------------------------------------------------------

mapfile -t ROLE_CARDS < <(ls "$AUDIT_DIR"/*.md 2>/dev/null | grep -vE "/completion\.md$|/pr-body-audit\.md$" || true)

if [ "${#ROLE_CARDS[@]}" -eq 0 ]; then
    check_fail "SC-15: audit role cards enumerated" "no role cards found in skills/audit/tasks"
else
    check_pass "SC-15: audit role cards enumerated (${#ROLE_CARDS[@]} files)"

    # --- RED 3: zero role cards cite the taxonomy via the 080 redirect ---
    # RED-state: 12 role cards link `Read [Evidence Type Taxonomy](guidelines/080-
    # code-standards.md)`. GREEN repoints these to the canonical reference.
    REDIRECT_080=""
    for card in "${ROLE_CARDS[@]}"; do
        if grep -q "Read \[Evidence Type Taxonomy\](guidelines/080-code-standards.md)" "$card"; then
            REDIRECT_080="$REDIRECT_080 $(basename "$card")"
        fi
    done
    if [ -n "$REDIRECT_080" ]; then
        check_fail "SC-15: zero role cards cite taxonomy via 080-code-standards redirect" \
            "redirect citation remains in:$REDIRECT_080"
    else
        check_pass "SC-15: zero role cards cite taxonomy via 080-code-standards redirect"
    fi

    # --- RED 4: zero role cards cite the taxonomy via spec-structure-standards redirect ---
    REDIRECT_STRUCT=""
    for card in "${ROLE_CARDS[@]}"; do
        if grep -q "spec-structure-standards.md.*§Evidence Type Taxonomy" "$card"; then
            REDIRECT_STRUCT="$REDIRECT_STRUCT $(basename "$card")"
        fi
    done
    if [ -n "$REDIRECT_STRUCT" ]; then
        check_fail "SC-15: zero role cards cite taxonomy via spec-structure-standards redirect" \
            "redirect citation remains in:$REDIRECT_STRUCT"
    else
        check_pass "SC-15: zero role cards cite taxonomy via spec-structure-standards redirect"
    fi

    # --- RED 5: zero role cards cite the taxonomy via the 080 guideline redirect (guideline-audit) ---
    REDIRECT_GUIDELINE=""
    for card in "${ROLE_CARDS[@]}"; do
        if grep -q "080-code-standards.md\` — .*evidence type taxonomy" "$card"; then
            REDIRECT_GUIDELINE="$REDIRECT_GUIDELINE $(basename "$card")"
        fi
    done
    if [ -n "$REDIRECT_GUIDELINE" ]; then
        check_fail "SC-15: zero role cards cite taxonomy via 080-code-standards guideline redirect" \
            "redirect citation remains in:$REDIRECT_GUIDELINE"
    else
        check_pass "SC-15: zero role cards cite taxonomy via 080-code-standards guideline redirect"
    fi

    # --- RED 6: every taxonomy-citing role card now cites the canonical reference ---
    # A role card is "taxonomy-citing" if it references the evidence-type taxonomy
    # (via any of the citation forms, direct or redirect). Every such card MUST
    # cite the single canonical reference.
    MISSING_CANONICAL=""
    for card in "${ROLE_CARDS[@]}"; do
        if grep -q "Evidence Type Taxonomy\|evidence type taxonomy\|evidence-type taxonomy\|evidence type declarations" "$card"; then
            if ! grep -q "cost-model-standards" "$card"; then
                MISSING_CANONICAL="$MISSING_CANONICAL $(basename "$card")"
            fi
        fi
    done
    if [ -n "$MISSING_CANONICAL" ]; then
        check_fail "SC-15: taxonomy-citing role cards cite the canonical reference" \
            "missing canonical citation in:$MISSING_CANONICAL"
    else
        check_pass "SC-15: taxonomy-citing role cards cite the canonical reference"
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-15 (taxonomy source consolidation) not yet implemented."
    echo "spec-creation/tasks/validate.md hardcodes the evidence-type lookup table instead of"
    echo "citing the canonical reference, and the audit role cards cite the evidence-type"
    echo "taxonomy from redirect sources (080-code-standards.md guideline, spec-structure-"
    echo "standards.md) rather than the single canonical reference document."
    echo "GREEN points every taxonomy citation at reference/cost-model-standards.md, loaded"
    echo "dynamically by both validate and audit."
    echo ""
    exit 1
fi
echo "SC-15 is GREEN — spec-creation/tasks/validate.md and every audit role card cite the"
echo "single canonical evidence-type taxonomy reference (reference/cost-model-standards.md),"
echo "loaded dynamically, with zero redirect-source taxonomy citations remaining."
echo ""
exit 0

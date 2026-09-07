#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# RED enforcement test: .opencode#2430 SC-1 (string) — deck lint reports ZERO
# guard-verbatim-missing findings across all 51 SKILL.md cards.
#
# SC-1 criterion: every SKILL.md — 48 top-level cards plus 3 nested platform
# cards (issue-operations/platforms/{github-mcp,gitbucket-api,local}/SKILL.md),
# 51 total — embeds the canonical mechanical guard verbatim; deck lint reports
# zero cards missing/deviant.
#
# RED describes what fails (plan-03 step 15): the deck-lint guard-verbatim
# check (phase-2 rule, lint_skill_guard_verbatim in skildeck-lint) run over
# all 51 SKILL.md files reports cards missing/deviant guard — every card
# still carries the prose-only variant. This is the phase-2 rule's
# intentional pre-sweep RED window: the rule landed in phase 2 and correctly
# flags the entire deck before the phase-3 GREEN sweep replaces the prose
# guard with the canonical mechanical guard.
#
# RED semantics: this test executes the linter (the system under test) and
# asserts ZERO guard-verbatim-missing findings across the deck. The assertion
# FAILs (exit 1) because all 51 cards are flagged today — a genuine RED, not
# a FALSE. Once the phase-3 GREEN sweep lands, the deck is clean and this
# test passes.
#
# Usage:  bash .opencode/tests-v2/test-2430-sc1-deck-lint-guard-verbatim-zero-red.sh
# Exit:   0 = GREEN (zero guard-verbatim-missing findings across all 51 cards)
#         1 = RED  (one or more guard-verbatim-missing findings — cards still
#                   missing/deviant guard; expected state before the sweep)
#         2 = BLOCKED (precondition failure — phase-1 reference doc missing,
#                      phase-2 rule missing, or deck enumeration != 51)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILDECK="$PROJECT_DIR/.opencode/tools/skildeck"
LINTER_IMPL="$PROJECT_DIR/.opencode/tools/impl/skildeck/skildeck-lint"
CANONICAL_REF="$PROJECT_DIR/.opencode/guidelines/023-pre-flight-guard.md"
SKILLS_DIR="$PROJECT_DIR/.opencode/skills"
EXPECTED_TOP_LEVEL=48
EXPECTED_NESTED=3
EXPECTED_TOTAL=51

echo "=== RED: #2430 SC-1 — deck lint reports ZERO guard-verbatim findings ==="
echo ""

# --- Precondition 1: canonical guard reference exists (phase 1 landed) ------
if [ ! -f "$CANONICAL_REF" ]; then
    echo "BLOCKED: canonical guard reference not found at $CANONICAL_REF (phase 1 not landed)" >&2
    exit 2
fi
echo "Precondition OK: canonical guard reference: $CANONICAL_REF"

# --- Precondition 2: phase-2 guard-verbatim rule exists in the linter -------
if ! grep -q "def lint_skill_guard_verbatim" "$LINTER_IMPL" \
    || ! grep -q '"guard-verbatim-missing"' "$LINTER_IMPL"; then
    echo "BLOCKED: guard-verbatim rule (lint_skill_guard_verbatim / guard-verbatim-missing) not found in $LINTER_IMPL (phase 2 not landed)" >&2
    exit 2
fi
echo "Precondition OK: phase-2 guard-verbatim rule present in linter"

# --- Precondition 3: deck enumeration is 48 top-level + 3 nested = 51 -------
TOP_LEVEL_COUNT=$(find "$SKILLS_DIR" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l)
NESTED_COUNT=$(find "$SKILLS_DIR" -path '*platforms/*/SKILL.md' | wc -l)
TOTAL_COUNT=$((TOP_LEVEL_COUNT + NESTED_COUNT))
echo "Deck enumeration: $TOP_LEVEL_COUNT top-level + $NESTED_COUNT nested = $TOTAL_COUNT cards"
if [ "$TOP_LEVEL_COUNT" -ne "$EXPECTED_TOP_LEVEL" ] \
    || [ "$NESTED_COUNT" -ne "$EXPECTED_NESTED" ] \
    || [ "$TOTAL_COUNT" -ne "$EXPECTED_TOTAL" ]; then
    echo "BLOCKED: deck enumeration drift — expected $EXPECTED_TOP_LEVEL top-level + $EXPECTED_NESTED nested = $EXPECTED_TOTAL, found $TOP_LEVEL_COUNT + $NESTED_COUNT = $TOTAL_COUNT" >&2
    exit 2
fi

# --- Execute the linter over the full deck -----------------------------------
LINT_OUTPUT=$("$SKILDECK" lint --json 2>/dev/null || true)
if [ -z "$LINT_OUTPUT" ]; then
    echo "FAIL: skildeck lint --json produced no output for the full deck" >&2
    exit 1
fi

# --- RED assertion: ZERO guard-verbatim-missing findings across the deck -----
read -r GV_TOTAL GV_CANONICAL_MISSING <<< "$(echo "$LINT_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
gv = [f for f in data if f.get('rule_id') == 'guard-verbatim-missing']
cm = [f for f in data if f.get('rule_id') == 'guard-verbatim-canonical-missing']
print(len(gv), len(cm))
" 2>/dev/null || echo '0 0')"

# A canonical-missing finding means the guard-verbatim rule could not run —
# the linter surfaced a hard failure. Treat as BLOCKED, never a silent pass.
if [ "${GV_CANONICAL_MISSING:-0}" -gt 0 ]; then
    echo "BLOCKED: guard-verbatim rule cannot run — canonical guard reference missing or unparseable (guard-verbatim-canonical-missing finding present)" >&2
    exit 2
fi

echo ""
echo "--- deck lint guard-verbatim findings (all must be gone for SC-1) ---"
echo "$LINT_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
gv = [f for f in data if f.get('rule_id') == 'guard-verbatim-missing']
for f in gv:
    print(f\"  {f.get('source')}: {f.get('message')}\")
print(f'  total: {len(gv)} of $TOTAL_COUNT cards flagged')
" 2>/dev/null || echo "$LINT_OUTPUT"
echo ""

if [ "${GV_TOTAL:-0}" -eq 0 ]; then
    echo ""
    echo "PASS: deck lint reports ZERO guard-verbatim-missing findings across"
    echo "all $TOTAL_COUNT SKILL.md cards — the canonical mechanical guard is"
    echo "embedded deck-wide. SC-1 is GREEN."
    echo ""
    exit 0
fi

echo ""
echo "FAIL: deck lint reports $GV_TOTAL guard-verbatim-missing finding(s) across"
echo "the $TOTAL_COUNT-card deck — cards still carry the prose-only (or deviant)"
echo "guard variant. The phase-3 card sweep (GREEN) has not landed yet."
echo "This is the RED state for SC-1."
echo ""
exit 1

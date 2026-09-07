#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# RED enforcement test: .opencode#2430 SC-6a (structural) — deck lint flags a
# fixture card missing the canonical Pre-Flight Guard.
#
# RED describes what fails: with no guard-verbatim rule present, deck lint run
# against a fixture card (missing the guard) reports no flag.
#
# Baseline note (2026-09-06): the deck already carries the #2339 marker-based
# rule (lint_skill_preflight_guard, commit 4eff82ec) which fires
# skill-preflight-guard-missing when the literal marker string
# ORCHESTRATOR_ONLY_SKILL_CARD is absent. SC-6a's deliverable is the phase-2
# guard-verbatim rule — a content-based, position-independent check against
# the canonical guard block text from .opencode/guidelines/023-pre-flight-guard.md
# (plan-02 Cross-Cutting SCs, plan-02 Interface Boundaries). The canonical
# rule_id for that rule is guard-verbatim-missing (plan-02 Cross-Cutting SCs:
# "lint assertions key on the card-class reason code ORCHESTRATOR_ONLY_SKILL_CARD",
# rule id namespace 'guard-verbatim', fixture naming from plan-02 code-path text).
# A deviant (prose-only) guard variant CAN contain the marker string and evade
# the #2339 marker rule — the exact deviance the guard-verbatim rule must catch.
#
# RED semantics: this test executes the linter (the system under test) and
# asserts that a guard-verbatim-missing finding exists for the fixture. The
# assertion FAILs (exit 1) because the guard-verbatim rule does not exist yet
# — a genuine RED, not a FALSE. Once GREEN lands, the fixture produces the
# finding and the assertion passes.
#
# Fixture: tmp/2430/fixtures/guard-missing/ (created by this script, idempotent)
# Usage:   bash .opencode/tests-v2/test-2430-sc6a-deck-lint-guard-verbatim-red.sh
# Exit:    0 = GREEN (guard-verbatim rule flags the fixture)
#          1 = RED  (no guard-verbatim-missing finding — rule not yet implemented)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILDECK="$PROJECT_DIR/.opencode/tools/skildeck"
FIXTURE_DIR="$PROJECT_DIR/tmp/2430/fixtures"
SCAN_DIR="$FIXTURE_DIR/guard-missing/skills"
FIXTURE_CARD="$SCAN_DIR/2430-guard-missing/SKILL.md"
CANONICAL_REF="$PROJECT_DIR/.opencode/guidelines/023-pre-flight-guard.md"

echo "=== RED: #2430 SC-6a — deck lint guard-verbatim flagging ==="
echo ""

# --- Fixture setup (idempotent) -------------------------------------------
if [ ! -f "$FIXTURE_CARD" ]; then
    mkdir -p "$SCAN_DIR/2430-guard-missing"
    cat > "$FIXTURE_CARD" <<'FIXTUREEOF'
---
name: 2430-guard-missing
description: "Fixture skill for .opencode#2430 SC-6a RED: minimal valid card with NO Pre-Flight Guard section. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: 2430-guard-missing

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "run task" | `run` | `sub-task` | {issue_number} |

## Workflows

1. Run the task.
FIXTUREEOF
fi

echo "Fixture: $FIXTURE_CARD"
echo "Canonical guard reference: $CANONICAL_REF"
echo ""

# --- Precondition: canonical guard reference exists (phase 1 landed) -------
if [ ! -f "$CANONICAL_REF" ]; then
    echo "BLOCKED: canonical guard reference not found at $CANONICAL_REF" >&2
    exit 2
fi

# --- Execute the linter against the guard-missing fixture -------------------
LINT_OUTPUT=$("$SKILDECK" lint --dir "$SCAN_DIR" --skill 2430-guard-missing --json 2>/dev/null || true)
if [ -z "$LINT_OUTPUT" ]; then
    echo "FAIL: skildeck-lint produced no output for the guard-missing fixture" >&2
    echo "" >&2
    echo "RED state: fixture lint run silent — no flag of any kind (hard RED)." >&2
    exit 1
fi

echo "--- deck lint findings on guard-missing fixture ---"
echo "$LINT_OUTPUT" | python3 -c "
import sys, json
for f in json.load(sys.stdin):
    print(f\"  [{f.get('rule_id','(none)')}] {f.get('source')}: {f.get('message')}\")
" 2>/dev/null || echo "$LINT_OUTPUT"
echo ""

# --- RED assertion: guard-verbatim-missing finding exists -------------------
GV_COUNT=$(echo "$LINT_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if f.get('rule_id') == 'guard-verbatim-missing')
print(count)
" 2>/dev/null || echo "0")

if [ "$GV_COUNT" -gt 0 ]; then
    echo ""
    echo "PASS: guard-verbatim rule flagged the guard-missing fixture ($GV_COUNT finding)."
    echo "SC-6a is GREEN — a missing guard can never produce a silent PASS."
    echo ""
    exit 0
fi

echo ""
echo "FAIL: no guard-verbatim-missing finding for fixture 2430-guard-missing."
echo "Only the #2339 marker rule fired (or nothing fired) — the SC-6a"
echo "guard-verbatim rule does not exist yet. This is the RED state."
echo ""
exit 1

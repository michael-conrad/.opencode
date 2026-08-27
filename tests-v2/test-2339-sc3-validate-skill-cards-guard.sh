#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral enforcement test: .opencode#2339 SC-3 — validate_skill_cards.py
# guard enforcement. The skill card validator (validate_skill_cards.py) SHALL
# flag a SKILL.md that lacks the pre-flight guard and SHALL NOT flag a card
# with the guard (idempotent — no double-guard finding).
#
# Maps to SC-3 from issue #2339:
#   The skill card validation tool (validate_skill_cards.py) flags a SKILL.md
#   that lacks the pre-flight guard.
#
# Evidence type: behavioral — run validate_skill_cards.py against a card with
#   and without the guard and inspect its output; assert a finding when the
#   guard is missing and no finding when present.
#
# RED: On the current validator there is no pre-flight-guard rule, so running
#   validate_skill_cards.py against an unguarded fixture SKILL.md produces no
#   guard finding. The assertion "unguarded card produces a finding" FAILs
#   (exit 1) — a genuine RED, not a FALSE (it executes the validator, the
#   system under test, and observes the absence of the expected finding).
#
# GREEN: add a pre-flight-guard REQ rule to validate_skill_cards.py, at which
#   point the unguarded fixture produces a finding and the guarded fixture
#   produces none. Both assertions PASS (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2339-sc3-validate-skill-cards-guard.sh
# Exit:  0 if validate_skill_cards.py flags the unguarded card and passes the
#         guarded card (GREEN), 1 otherwise (RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

VALIDATOR="$PROJECT_DIR/.opencode/skills/skill-creator/scripts/validate_skill_cards.py"
# The validator is a PEP 723 uv script (not marked executable), so invoke via
# `uv run --script` regardless of how the test itself is launched.
UV_RUN_CMD=(uv run --script "$VALIDATOR")
FIXTURE_BASE="$PROJECT_DIR/.opencode/tmp/2339-sc3-fixture"

RULE_ID="skill-preflight-guard-missing"

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
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

# --- Set up the fixture skills --------------------------------------------
# Each scenario uses its own fixture project root so the unguarded card
# cannot contaminate the guarded-card run (the validator scans every card
# under its CWD's .opencode/skills/ tree).
rm -rf "$FIXTURE_BASE"
mkdir -p "$FIXTURE_BASE/unguarded/.opencode/skills/2339-unguarded"
mkdir -p "$FIXTURE_BASE/guarded/.opencode/skills/2339-guarded"

cat > "$FIXTURE_BASE/unguarded/.opencode/skills/2339-unguarded/SKILL.md" <<'UNGUARDEDEOF'
---
name: 2339-unguarded
description: "Fixture skill for SC-3 validate_skill_cards.py guard enforcement testing. Intentionally lacks the pre-flight guard. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: 2339-unguarded

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "run task" | `run` | `sub-task` | {issue_number} |
UNGUARDEDEOF

cat > "$FIXTURE_BASE/guarded/.opencode/skills/2339-guarded/SKILL.md" <<'GUARDEDEOF'
---
name: 2339-guarded
description: "Fixture skill for SC-3 validate_skill_cards.py guard enforcement testing. Carries the canonical pre-flight guard. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: 2339-guarded

## Pre-Flight Guard (Mandatory)

**This skill card is orchestrator-only routing metadata.**

If you are a sub-agent (dispatched via `task()`), you MUST NOT consume the routing metadata below. Sub-agents cannot call `task()` and cannot execute orchestrator-level dispatch instructions. Return `BLOCKED` with reason `ORCHESTRATOR_ONLY_SKILL_CARD` and halt.

If you are the orchestrator (loaded this card via `skill({name: "..."})`), proceed to the Workflows section.

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "run task" | `run` | `sub-task` | {issue_number} |
GUARDEDEOF

echo ""
echo "=== SC-3: validate_skill_cards.py pre-flight guard enforcement (#2339) ==="
echo ""

count_guard_findings() {
    # $1 = JSON output from validate_skill_cards.py --json
    echo "$1" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
except Exception:
    print(0)
    sys.exit(0)
count = sum(1 for f in data if f.get('rule_id') == '$RULE_ID')
print(count)
"
}

# --- Unguarded card must produce a guard finding -------------------------
UNGUARDED_OUTPUT=$(
    cd "$FIXTURE_BASE/unguarded" && "${UV_RUN_CMD[@]}" --json 2>/dev/null || true
)
if [ -z "$UNGUARDED_OUTPUT" ]; then
    check_fail "SC-3: unguarded card flagged" "validate_skill_cards.py produced no JSON output"
else
    UNGUARDED_COUNT=$(count_guard_findings "$UNGUARDED_OUTPUT")
    if [ "$UNGUARDED_COUNT" -gt 0 ]; then
        check_pass "SC-3: unguarded card flagged (skill-preflight-guard-missing, $UNGUARDED_COUNT finding)"
    else
        check_fail "SC-3: unguarded card flagged" "no $RULE_ID finding for 2339-unguarded (RED phase expected)"
    fi
fi

# --- Guarded card must produce no guard finding ---------------------------
GUARDED_OUTPUT=$(
    cd "$FIXTURE_BASE/guarded" && "${UV_RUN_CMD[@]}" --json 2>/dev/null || true
)
if [ -z "$GUARDED_OUTPUT" ]; then
    check_fail "SC-3: guarded card passed" "validate_skill_cards.py produced no JSON output"
else
    GUARDED_COUNT=$(count_guard_findings "$GUARDED_OUTPUT")
    if [ "$GUARDED_COUNT" -eq 0 ]; then
        check_pass "SC-3: guarded card not flagged (no $RULE_ID finding)"
    else
        check_fail "SC-3: guarded card not flagged" "$GUARDED_COUNT $RULE_ID finding(s) for guarded card"
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3 (#2339) validate_skill_cards.py does not yet enforce the pre-flight guard."
    echo ""
    echo "--- current validator findings on unguarded fixture ---"
    echo "$UNGUARDED_OUTPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(0)
for f in data:
    print(f\"  [{f.get('rule_id','')}] {f.get('file_path')}: {f.get('message')}\")
" 2>/dev/null || true
    echo ""
    exit 1
fi
echo "SC-3 is GREEN — validate_skill_cards.py flags the unguarded card and passes the guarded card."
echo ""
exit 0

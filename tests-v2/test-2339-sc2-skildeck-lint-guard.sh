#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral enforcement test: .opencode#2339 SC-2 — skildeck-lint guard
# enforcement. The skill card linting tool (skildeck-lint) SHALL flag a
# SKILL.md that lacks the pre-flight guard and SHALL NOT flag a card with
# the guard (idempotent — no double-guard finding).
#
# Maps to SC-2 from issue #2339:
#   The skill card linting tool (skildeck-lint) flags a SKILL.md that lacks
#   the pre-flight guard.
#
# Evidence type: behavioral — run skildeck-lint against a card with and
#   without the guard and inspect its output; assert a finding when the
#   guard is missing and no finding when present.
#
# RED: On the current linter there is no lint_skill_preflight_guard rule, so
#   running skildeck-lint against an unguarded fixture SKILL.md produces no
#   guard finding. The assertion "unguarded card produces a finding" FAILs
#   (exit 1) — a genuine RED, not a FALSE (it executes the linter, the system
#   under test, and observes the absence of the expected finding).
#
# GREEN: add lint_skill_preflight_guard to skildeck-lint, at which point the
#   unguarded fixture produces a finding and the guarded fixture produces
#   none. Both assertions PASS (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2339-sc2-skildeck-lint-guard.sh
# Exit:  0 if skildeck-lint flags the unguarded card and passes the guarded
#         card (GREEN), 1 otherwise (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILDECK="$PROJECT_DIR/.opencode/tools/skildeck"
FIXTURE_BASE="$PROJECT_DIR/.opencode/tmp/2339-sc2-fixture"

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
# Each scenario uses its own scan dir so the unguarded card cannot
# contaminate the guarded-card run (the guard rule scans all skill dirs).
rm -rf "$FIXTURE_BASE"
mkdir -p "$FIXTURE_BASE/unguarded/skills/2339-unguarded"
mkdir -p "$FIXTURE_BASE/guarded/skills/2339-guarded"

cat > "$FIXTURE_BASE/unguarded/skills/2339-unguarded/SKILL.md" <<'UNGUARDEDEOF'
---
name: 2339-unguarded
description: "Fixture skill for SC-2 skildeck-lint guard enforcement testing. Intentionally lacks the pre-flight guard. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: 2339-unguarded

## Trigger Dispatch Table

| User says / Context | Task | Dispatch | Context passed |
|---------------------|------|----------|----------------|
| "run task" | `run` | `sub-task` | {issue_number} |
UNGUARDEDEOF

cat > "$FIXTURE_BASE/guarded/skills/2339-guarded/SKILL.md" <<'GUARDEDEOF'
---
name: 2339-guarded
description: "Fixture skill for SC-2 skildeck-lint guard enforcement testing. Carries the canonical pre-flight guard. Not a real skill."
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
echo "=== SC-2: skildeck-lint pre-flight guard enforcement (#2339) ==="
echo ""

# --- Unguarded card must produce a guard finding -------------------------
UNGUARDED_OUTPUT=$("$SKILDECK" lint --dir "$FIXTURE_BASE/unguarded/skills" --skill 2339-unguarded --json 2>/dev/null || true)
if [ -z "$UNGUARDED_OUTPUT" ]; then
    check_fail "SC-2: unguarded card flagged" "skildeck-lint produced no JSON output"
else
    UNGUARDED_COUNT=$(echo "$UNGUARDED_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if f.get('rule_id') == 'skill-preflight-guard-missing')
print(count)
" 2>/dev/null || echo "0")
    if [ "$UNGUARDED_COUNT" -gt 0 ]; then
        check_pass "SC-2: unguarded card flagged (skill-preflight-guard-missing, $UNGUARDED_COUNT finding)"
    else
        check_fail "SC-2: unguarded card flagged" "no skill-preflight-guard-missing finding for 2339-unguarded (RED phase expected)"
    fi
fi

# --- Guarded card must produce no guard finding ---------------------------
GUARDED_OUTPUT=$("$SKILDECK" lint --dir "$FIXTURE_BASE/guarded/skills" --skill 2339-guarded --json 2>/dev/null || true)
if [ -z "$GUARDED_OUTPUT" ]; then
    check_fail "SC-2: guarded card passed" "skildeck-lint produced no JSON output"
else
    GUARDED_COUNT=$(echo "$GUARDED_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if f.get('rule_id') == 'skill-preflight-guard-missing')
print(count)
" 2>/dev/null || echo "0")
    if [ "$GUARDED_COUNT" -eq 0 ]; then
        check_pass "SC-2: guarded card not flagged (no skill-preflight-guard-missing finding)"
    else
        check_fail "SC-2: guarded card not flagged" "$GUARDED_COUNT skill-preflight-guard-missing finding(s) for guarded card"
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (#2339) skildeck-lint does not yet enforce the pre-flight guard."
    echo ""
    echo "--- current linter findings on unguarded fixture ---"
    echo "$UNGUARDED_OUTPUT" | python3 -c "
import sys, json
for f in json.load(sys.stdin):
    print(f\"  [{f.get('rule_id','')}] {f.get('source')}: {f.get('message')}\")
" 2>/dev/null || true
    echo ""
    exit 1
fi
echo "SC-2 is GREEN — skildeck-lint flags the unguarded card and passes the guarded card."
echo ""
exit 0

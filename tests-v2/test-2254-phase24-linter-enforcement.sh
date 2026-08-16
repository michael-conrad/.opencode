#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# RED enforcement test for Spec .opencode#2254 Phase 24 — skildeck linter
# extension for task-card enforcement rules SC-44, SC-45, SC-46.
#
# SC-44 (behavioral): The skildeck linter SHALL enforce broken markdown-link
#   targets across task cards (not just SKILL.md Workflows dispatch lines),
#   flagging references that resolve to non-existent files.
# SC-45 (behavioral): The skildeck linter SHALL enforce the
#   no-YAML-frontmatter-on-task-cards rule, flagging any task card that
#   carries YAML frontmatter.
# SC-46 (behavioral): The skildeck linter SHALL enforce dispatch-contract
#   completeness including result-contract field-name matching (B2) and no
#   over-supplied/unconsumed context params (B1).
#
# RED: This test asserts the linter flags the three task-card defect classes
# in a fixture skill. On the current linter (R5 checks only SKILL.md Workflows
# dispatch lines; there is no task-card link rule, no task-card frontmatter
# rule, and the dispatch-contract rule R4 checks only Context ⊇ Entry
# Criteria — not over-supplied params or Result Contract field matching), none
# of the three new rule classes are produced. The test therefore FAILs (exit
# 1) — a genuine RED, not a FALSE (it executes the linter, the system under
# test, and observes the absence of the expected findings).
#
# GREEN: extend skildeck-lint to produce task-card-link-broken (SC-44),
# task-card-frontmatter (SC-45), and dispatch-contract completeness findings
# (SC-46), at which point the assertions below PASS (exit 0).
#
# Evidence type: The SCs are declared behavioral; this content-verification
# enforcement test is the RED/GREEN gate that directly exercises the linter
# (the modified component) and asserts the three rule classes. Full opencode
# run behavioral evidence is captured by the paired behavioral test
# (tests-v2/behaviors/2254-sc44-sc45-sc46-linter-enforcement.sh).
#
# Usage: bash .opencode/tests-v2/test-2254-phase24-linter-enforcement.sh
# Exit:  0 if the linter flags all three task-card defect classes (GREEN),
#        1 otherwise (RED).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILDECK="$PROJECT_DIR/.opencode/tools/skildeck"
FIXTURE_BASE="$PROJECT_DIR/.opencode/tmp/phase24-fixture"
SKILL_DIR="$FIXTURE_BASE/skills/skildeck-taskcard-violation"

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

# --- Set up the violating fixture skill ------------------------------------
rm -rf "$FIXTURE_BASE"
mkdir -p "$SKILL_DIR/tasks"

cat > "$SKILL_DIR/SKILL.md" <<'SKILLEOF'
---
name: skildeck-taskcard-violation
description: "Fixture skill for SC-44/SC-45/SC-46 linter task-card enforcement testing. Not a real skill."
license: MIT
compatibility: opencode
---

# Skill: skildeck-taskcard-violation

## Workflows

### Run a task

- [ ] 1. **dispatch** — Dispatch `task(..., prompt: "Follow the instructions in [skildeck-taskcard-violation/tasks/dispatch.md](.opencode/skills/skildeck-taskcard-violation/tasks/dispatch.md)")`
  - **Execution mode:** inline (this step supplies context)
  - **Context passed:** `{issue_number, project_root, unconsumed_param}`
  - **Returns:** `{status, finding_summary}`
SKILLEOF

cat > "$SKILL_DIR/tasks/dispatch.md" <<'DISPATCHEOF'
# Task: dispatch

## Dispatch Contract

- [ ] `issue_number` accepted
- [ ] `project_root` accepted

## Result Contract

status, summary
DISPATCHEOF

cat > "$SKILL_DIR/tasks/broken-link.md" <<'BROKENLINKEOF'
# Task: broken-link

## Procedure

- [ ] 1. Follow the instructions in [skildeck-taskcard-violation/tasks/missing.md](.opencode/skills/skildeck-taskcard-violation/tasks/missing.md).
- [ ] 2. Return the result contract.
BROKENLINKEOF

cat > "$SKILL_DIR/tasks/frontmatter.md" <<'FRONTMATTEREOF'
---
name: frontmatter
description: "Task card that carries YAML frontmatter (SC-45 violation)."
provenance: AI-generated
---

# Task: frontmatter

## Procedure

- [ ] 1. Return the result contract.
FRONTMATTEREOF

echo ""
echo "=== Phase 24 — skildeck linter task-card enforcement (Spec .opencode#2254) ==="
echo ""

JSON_OUTPUT=$("$SKILDECK" lint --dir "$FIXTURE_BASE/skills" --skill skildeck-taskcard-violation --json 2>/dev/null || true)

if [ -z "$JSON_OUTPUT" ]; then
    check_fail "Phase 24: skildeck lint --json" "output is empty"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    exit 1
fi

# --- SC-44: task-card broken link -----------------------------------------
SC44_COUNT=$(echo "$JSON_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if f.get('rule_id') == 'task-card-link-broken')
print(count)
" 2>/dev/null || echo "0")

if [ "$SC44_COUNT" -gt 0 ]; then
    check_pass "SC-44: linter flags broken task-card link (task-card-link-broken, $SC44_COUNT findings)"
else
    check_fail "SC-44: linter flags broken task-card link" "no task-card-link-broken finding for broken-link.md -> missing.md"
fi

# --- SC-45: no-YAML-frontmatter-on-task-cards -----------------------------
SC45_COUNT=$(echo "$JSON_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if f.get('rule_id') == 'task-card-frontmatter')
print(count)
" 2>/dev/null || echo "0")

if [ "$SC45_COUNT" -gt 0 ]; then
    check_pass "SC-45: linter flags task-card YAML frontmatter (task-card-frontmatter, $SC45_COUNT findings)"
else
    check_fail "SC-45: linter flags task-card YAML frontmatter" "no task-card-frontmatter finding for frontmatter.md"
fi

# --- SC-46: dispatch-contract completeness --------------------------------
SC46_COUNT=$(echo "$JSON_OUTPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
count = sum(1 for f in data if str(f.get('rule_id','')).startswith('dispatch-contract'))
print(count)
" 2>/dev/null || echo "0")

if [ "$SC46_COUNT" -gt 0 ]; then
    check_pass "SC-46: linter flags dispatch-contract mismatch (dispatch-contract-*, $SC46_COUNT findings)"
else
    check_fail "SC-46: linter flags dispatch-contract mismatch" "no dispatch-contract completeness finding for over-supplied 'unconsumed_param' / Returns 'finding_summary' mismatch"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "Phase 24 is RED — the skildeck linter does not yet enforce the three"
    echo "task-card rules (SC-44 broken task-card links, SC-45 task-card YAML"
    echo "frontmatter, SC-46 dispatch-contract completeness). Expected FAIL on"
    echo "current code."
    echo ""
    echo "--- current linter findings on the fixture skill ---"
    echo "$JSON_OUTPUT" | python3 -c "
import sys, json
for f in json.load(sys.stdin):
    print(f\"  [{f.get('rule_id','')}] {f.get('source')}: {f.get('message')}\")
" 2>/dev/null || true
    exit 1
fi
echo "Phase 24 is GREEN — the extended linter flags all three task-card defect"
echo "classes (SC-44, SC-45, SC-46)."
echo ""
exit 0

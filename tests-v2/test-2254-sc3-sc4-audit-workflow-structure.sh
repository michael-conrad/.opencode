#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-3, SC-4 — audit/SKILL.md Workflows structure
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-02-audit-skill-structure — SC-3, SC-4 (string),
#        `.opencode/skills/audit/SKILL.md`.
#
# SC-3 (string): audit/SKILL.md SHALL use a single Workflows section with
#   4 DiMo steps (Investigator, Validator, Evaluator, Arbiter).
#
# SC-4 (string): audit/SKILL.md SHALL NOT contain Trigger Dispatch Table, Tasks,
#   or Invocation sections.
#
# RED state: audit/SKILL.md currently has the old multi-section structure
#   (`## Trigger Dispatch Table`, `## Tasks`, `## Invocation`, `## DiMo Role
#   Chain Dispatch`) and NO `## Workflows` section. Assertions (a) and (b) FAIL.
#   GREEN converts it to a single Workflows section with 4 DiMo steps and removes
#   the TDT/Invocation/Tasks sections.
#
# Evidence type: SC-3 and SC-4 are `string` SCs. This content-verification test
#   greps audit/SKILL.md for presence/absence of the section headings. It is the
#   primary gate for these content-only SCs (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc3-sc4-audit-workflow-structure.sh
# Exit:  0 if the checks pass (GREEN), 1 if they fail (expected RED on SC-3/SC-4).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_MD="$PROJECT_DIR/.opencode/skills/audit/SKILL.md"

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
echo "=== SC-3, SC-4 — audit Workflows structure (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-3 (string): audit/SKILL.md SHALL use a single Workflows section with
#   4 DiMo steps (Investigator, Validator, Evaluator, Arbiter).
#
# (a) Exactly one `## Workflows` section heading.
# (b) Within that Workflows section, the 4 DiMo role steps are present:
#     Investigator, Validator, Evaluator, Arbiter.
# ---------------------------------------------------------------------------
echo "--- SC-3 (a): single '## Workflows' section heading ---"

WORKFLOWS_COUNT=$(grep -c '^## Workflows$' "$SKILL_MD" 2>/dev/null || true)
if [ "$WORKFLOWS_COUNT" -eq 1 ]; then
    check_pass "SC-3: audit/SKILL.md has exactly one '## Workflows' section"
else
    check_fail "SC-3: single '## Workflows' section" \
        "found $WORKFLOWS_COUNT '## Workflows' heading(s) in $SKILL_MD (expected 1)"
fi

echo "--- SC-3 (b): 4 DiMo role steps present ---"

# Extract the Workflows section body (from ## Workflows to the next ## heading)
WORKFLOWS_BODY=$(awk '/^## Workflows$/{flag=1;next} /^## /{flag=0} flag' "$SKILL_MD" 2>/dev/null || true)

for role in Investigator Validator Evaluator Arbiter; do
    if grep -q "$role" <<<"$WORKFLOWS_BODY"; then
        check_pass "SC-3: '$role' DiMo step present in Workflows section"
    else
        check_fail "SC-3: '$role' DiMo step present in Workflows section" \
            "no '$role' step found in audit/SKILL.md Workflows section"
    fi
done

# ---------------------------------------------------------------------------
# SC-4 (string): audit/SKILL.md SHALL NOT contain Trigger Dispatch Table, Tasks,
#   or Invocation sections.
#
# (c) Zero occurrences of `## Trigger Dispatch Table`.
# (d) Zero occurrences of `## Tasks`.
# (e) Zero occurrences of `## Invocation`.
# ---------------------------------------------------------------------------
echo "--- SC-4 (c): zero '## Trigger Dispatch Table' section ---"

TDT_COUNT=$(grep -c '^## Trigger Dispatch Table$' "$SKILL_MD" 2>/dev/null || true)
if [ "$TDT_COUNT" -eq 0 ]; then
    check_pass "SC-4: no '## Trigger Dispatch Table' section present in audit/SKILL.md"
else
    check_fail "SC-4: no '## Trigger Dispatch Table' section" \
        "found $TDT_COUNT '## Trigger Dispatch Table' heading(s) in $SKILL_MD"
fi

echo "--- SC-4 (d): zero '## Tasks' section ---"

TASKS_COUNT=$(grep -c '^## Tasks$' "$SKILL_MD" 2>/dev/null || true)
if [ "$TASKS_COUNT" -eq 0 ]; then
    check_pass "SC-4: no '## Tasks' section present in audit/SKILL.md"
else
    check_fail "SC-4: no '## Tasks' section" \
        "found $TASKS_COUNT '## Tasks' heading(s) in $SKILL_MD"
fi

echo "--- SC-4 (e): zero '## Invocation' section ---"

INVOCATION_COUNT=$(grep -c '^## Invocation$' "$SKILL_MD" 2>/dev/null || true)
if [ "$INVOCATION_COUNT" -eq 0 ]; then
    check_pass "SC-4: no '## Invocation' section present in audit/SKILL.md"
else
    check_fail "SC-4: no '## Invocation' section" \
        "found $INVOCATION_COUNT '## Invocation' heading(s) in $SKILL_MD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-3/SC-4 (audit Workflows structure) not yet implemented."
    echo "audit/SKILL.md still uses the old multi-section structure"
    echo "(TDT/Invocation/Tasks/DiMo Role Chain) and has no Workflows section."
    echo "GREEN converts it to a single Workflows section with 4 DiMo steps."
    echo ""
    exit 1
fi
echo "SC-3 and SC-4 are GREEN — audit/SKILL.md has a single Workflows section with"
echo "4 DiMo steps and no TDT/Invocation/Tasks sections."
echo ""
exit 0

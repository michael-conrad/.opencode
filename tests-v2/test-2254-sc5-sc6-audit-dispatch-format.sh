#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-5, SC-6 — audit/SKILL.md dispatch format
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-10-audit-dispatch-format — SC-5, SC-6 (string),
#        `.opencode/skills/audit/SKILL.md`.
#
# SC-5 (string): audit/SKILL.md SHALL use the canonical dispatch prompt format
#   `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all task()
#   dispatches.
#
# SC-6 (string): audit/SKILL.md SHALL NOT contain deprecated
#   `execute <task-name> DiMo <role> from audit` dispatch strings.
#
# RED state: audit/SKILL.md previously used deprecated
#   `execute <task> DiMo <role> from audit` dispatch strings and lacked the
#   canonical `Follow the instructions in [audit/tasks/<task>.md](...)` format.
#   Assertions (a) and (b) FAIL. GREEN converts the dispatch to the canonical
#   format and removes the deprecated DiMo strings.
#
# Evidence type: SC-5 and SC-6 are `string` SCs. This content-verification test
#   greps audit/SKILL.md for presence/absence of the dispatch strings. It is the
#   primary gate for these content-only SCs (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc5-sc6-audit-dispatch-format.sh
# Exit:  0 if the checks pass (GREEN), 1 if they fail (expected RED on SC-5/SC-6).

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
echo "=== SC-5, SC-6 — audit dispatch format (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-5 (string): audit/SKILL.md SHALL use the canonical dispatch prompt format
#   `Follow the instructions in [<skill>/tasks/<task>.md](...)` for all task()
#   dispatches.
#
# (a) At least one canonical dispatch string is present in the Workflows section.
# ---------------------------------------------------------------------------
echo "--- SC-5 (a): canonical dispatch format present ---"

CANONICAL_COUNT=$(grep -c 'Follow the instructions in \[audit/tasks/' "$SKILL_MD" 2>/dev/null || true)
if [ "$CANONICAL_COUNT" -ge 1 ]; then
    check_pass "SC-5: audit/SKILL.md uses canonical dispatch format (found $CANONICAL_COUNT)"
else
    check_fail "SC-5: canonical dispatch format present" \
        "no 'Follow the instructions in [audit/tasks/...]' dispatch string found in $SKILL_MD"
fi

# ---------------------------------------------------------------------------
# SC-6 (string): audit/SKILL.md SHALL NOT contain deprecated
#   `execute <task-name> DiMo <role> from audit` dispatch strings.
#
# (b) Zero occurrences of `execute .* DiMo .* from audit`.
# ---------------------------------------------------------------------------
echo "--- SC-6 (b): zero deprecated DiMo dispatch strings ---"

DIMO_COUNT=$(grep -c 'execute .* DiMo .* from audit' "$SKILL_MD" 2>/dev/null || true)
if [ "$DIMO_COUNT" -eq 0 ]; then
    check_pass "SC-6: no deprecated 'execute <task> DiMo <role> from audit' strings in audit/SKILL.md"
else
    check_fail "SC-6: no deprecated DiMo dispatch strings" \
        "found $DIMO_COUNT 'execute .* DiMo .* from audit' string(s) in $SKILL_MD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-5/SC-6 (audit dispatch format) not yet implemented."
    echo "audit/SKILL.md still uses deprecated DiMo dispatch strings and lacks the"
    echo "canonical 'Follow the instructions in [audit/tasks/<task>.md](...)' format."
    echo "GREEN converts the dispatch to the canonical format and removes the"
    echo "deprecated DiMo strings."
    echo ""
    exit 1
fi
echo "SC-5 and SC-6 are GREEN — audit/SKILL.md uses the canonical dispatch format"
echo "with zero deprecated DiMo dispatch strings."
echo ""
exit 0

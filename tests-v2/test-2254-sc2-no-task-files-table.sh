#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-2 — No Task Files Table
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-02-audit-skill-structure — SC-2 (string),
#        `.opencode/skills/spec-creation/SKILL.md`.
#
# SC-2 (string): spec-creation/SKILL.md SHALL NOT contain a `## Task Files` table.
#
# RED state: spec-creation/SKILL.md currently has a `## Task Files` table in the
#   Workflows section. Assertion (a) FAILS. GREEN removes the redundant table.
#
# Evidence type: SC-2 is a `string` SC. This content-verification test greps
#   spec-creation/SKILL.md for absence of the `## Task Files` heading. It is the
#   primary gate for this content-only SC (no runtime behavior is changed).
#
# Usage: bash .opencode/tests-v2/test-2254-sc2-no-task-files-table.sh
# Exit:  0 if the check passes (GREEN), 1 if it fails (expected RED on SC-2).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

SKILL_MD="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"

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
echo "=== SC-2 — No Task Files Table (Spec .opencode#2254) ==="
echo ""
echo "Target file: $SKILL_MD"
echo ""

# ---------------------------------------------------------------------------
# SC-2 (string): spec-creation/SKILL.md SHALL NOT contain a `## Task Files` table.
#
# (a) Zero occurrences of the `## Task Files` heading. RED-now: 1 occurrence
#     exists in the Workflows section.
# ---------------------------------------------------------------------------
echo "--- SC-2 (a): zero '## Task Files' table heading ---"

TASK_FILES_COUNT=$(grep -c '^## Task Files$' "$SKILL_MD" 2>/dev/null || true)
if [ "$TASK_FILES_COUNT" -eq 0 ]; then
    check_pass "SC-2: no '## Task Files' table present in spec-creation/SKILL.md"
else
    check_fail "SC-2: no '## Task Files' table present in spec-creation/SKILL.md" \
        "found $TASK_FILES_COUNT '## Task Files' heading(s) in $SKILL_MD"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-2 (no Task Files table) not yet implemented."
    echo "spec-creation/SKILL.md still contains a '## Task Files' table."
    echo "GREEN removes the redundant '## Task Files' table."
    echo ""
    exit 1
fi
echo "SC-2 is GREEN — spec-creation/SKILL.md has no '## Task Files' table."
echo ""
exit 0

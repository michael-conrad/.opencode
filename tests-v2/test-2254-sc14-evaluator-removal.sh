#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-Verification Enforcement Test: SC-14 — redundant evaluator removal
#
# Issue: .opencode#2254 — Spec-creation / audit skill card remediation.
# Phase: plan-13-redundant-evaluator-removal — SC-14 (string),
#        `.opencode/skills/audit/tasks/`.
#
# SC-14 (string): The redundant audit/tasks/behavioral-sc-evaluator.md SHALL be
#   removed.
#
# RED state: the redundant file audit/tasks/behavioral-sc-evaluator.md exists.
#   The assertion FAILS (file present). GREEN removes the redundant file.
#
# Evidence type: SC-14 is a `string` SC. This content-verification test checks
#   the file is absent and is the primary gate for this content-only SC.
#
# Usage: bash .opencode/tests-v2/test-2254-sc14-evaluator-removal.sh
# Exit:  0 if the check passes (GREEN), 1 if it fails (expected RED on SC-14).

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASKS_DIR="$PROJECT_DIR/.opencode/skills/audit/tasks"
TARGET="$TASKS_DIR/behavioral-sc-evaluator.md"

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
echo "=== SC-14 — redundant evaluator removal (Spec .opencode#2254) ==="
echo ""
echo "Target: $TARGET"
echo ""

# ---------------------------------------------------------------------------
# SC-14 (string): The redundant audit/tasks/behavioral-sc-evaluator.md SHALL be
#   removed.
# ---------------------------------------------------------------------------
echo "--- SC-14: behavioral-sc-evaluator.md is absent ---"

if [ -e "$TARGET" ]; then
    check_fail "SC-14: behavioral-sc-evaluator.md is present" \
        "$TARGET exists but must be removed (redundant file with zero consumers)"
else
    check_pass "SC-14: behavioral-sc-evaluator.md is absent"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""
if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-14 (redundant evaluator removal) not yet implemented."
    echo "The redundant file audit/tasks/behavioral-sc-evaluator.md remains."
    echo "GREEN removes the redundant file."
    echo ""
    exit 1
fi
echo "SC-14 is GREEN — the redundant audit/tasks/behavioral-sc-evaluator.md is removed."
echo ""
exit 0

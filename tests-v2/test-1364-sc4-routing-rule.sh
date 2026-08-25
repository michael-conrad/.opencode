#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: approval-gate for_pr routing rule
# Maps to SC-4 from issue #1364: the approval-gate skill SHALL contain a
# mandatory routing rule — for_pr with an existing plan MUST dispatch
# executing-plans; direct PR creation without plan execution is a critical
# violation.
#
# RED phase: the routing rule text is absent from approval-gate/SKILL.md, so
# this test FAILS.
# GREEN phase: after the mandatory routing rule is added to approval-gate/
# SKILL.md, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-1364-sc4-routing-rule.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

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

echo ""
echo "=== approval-gate for_pr Routing Rule -- SC-4 (#1364) ==="
echo ""

SKILL_FILE="$PROJECT_DIR/.opencode/skills/approval-gate/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
    check_fail "SC-4: SKILL.md present" "skill file not found: $SKILL_FILE"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

# SC-4: the approval-gate skill SHALL contain a mandatory routing rule that
# for_pr with an existing plan MUST dispatch executing-plans.
if grep -qiE "for_pr.*(MUST|must).*(dispatch|call).*executing-plans|executing-plans.*(MUST|must).*dispatch" "$SKILL_FILE"; then
    check_pass "SC-4: for_pr with existing plan MUST dispatch executing-plans"
else
    check_fail "SC-4: for_pr with existing plan MUST dispatch executing-plans" "approval-gate SKILL.md has no routing rule mandating executing-plans dispatch for for_pr"
fi

# SC-4: direct PR creation without plan execution SHALL be a critical violation.
if grep -qiE "direct PR creation without plan execution.*critical violation|critical violation.*direct PR creation" "$SKILL_FILE"; then
    check_pass "SC-4: direct PR creation without plan execution is a critical violation"
else
    check_fail "SC-4: direct PR creation without plan execution is a critical violation" "approval-gate SKILL.md does not mark direct PR creation without plan execution as a critical violation"
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0

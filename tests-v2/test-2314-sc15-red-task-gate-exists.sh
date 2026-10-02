#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: plan-existence gate in the
# test-driven-development RED task card (bypass-path surface)
# Maps to SC-15 from issue #2314: `test-driven-development/tasks/red.md`
# SHALL carry a plan.md-existence gate entry at the RED dispatch boundary —
# before RED work begins, verify an approved `plan.md` exists at the
# canonical path `{issues_prefix}/{N}/plan.md`; if absent, block with
# `PLAN_MISSING` (Tier 1 — developer authorization does not waive).
#
# RED phase: the gate entry is absent from the RED task card (red.md does
# NOT contain a plan.md-existence gate entry), so this test FAILS.
# GREEN phase: after the gate entry is added, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2314-sc15-red-task-gate-exists.sh
# Exit: 0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (zai-org/GLM-5.3-Flash)

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
echo "=== RED Task Plan-Existence Gate -- SC-15 (#2314) ==="
echo ""

RED_TASK="$PROJECT_DIR/.opencode/skills/test-driven-development/tasks/red.md"

# SC-15: RED task card SHALL carry the PLAN_MISSING gate entry.
if [ -f "$RED_TASK" ] && grep -qiE "PLAN_MISSING" "$RED_TASK"; then
    check_pass "SC-15: red task card carries PLAN_MISSING gate entry"
else
    check_fail "SC-15: red task card carries PLAN_MISSING gate entry" "test-driven-development/tasks/red.md has no PLAN_MISSING gate entry"
fi

# SC-15: the gate entry SHALL tie PLAN_MISSING to plan.md existence at the
# canonical path.
if [ -f "$RED_TASK" ] && grep -qiE "plan\.md" "$RED_TASK" && grep -qiE "PLAN_MISSING" "$RED_TASK"; then
    check_pass "SC-15: red task gate references plan.md existence"
else
    check_fail "SC-15: red task gate references plan.md existence" "red task card does not tie PLAN_MISSING to plan.md existence"
fi

# SC-15: the gate entry SHALL name the canonical plan path
# ({issues_prefix}/{N}/plan.md or the issues-prefix plan path pattern).
if [ -f "$RED_TASK" ] && grep -qiE "\{issues_prefix\}/\{N\}/plan\.md|issues-prefix.*plan\.md|plan\.md.*canonical" "$RED_TASK"; then
    check_pass "SC-15: red task gate names the canonical plan path"
else
    check_fail "SC-15: red task gate names the canonical plan path" "red task card gate entry does not name the canonical plan path {issues_prefix}/{N}/plan.md"
fi

# SC-15: the gate entry SHALL be Tier 1 (developer authorization does not
# waive).
if [ -f "$RED_TASK" ] && grep -qiE "PLAN_MISSING.*(Tier 1|does not waive|non-overridable)|Tier 1.*PLAN_MISSING" "$RED_TASK"; then
    check_pass "SC-15: PLAN_MISSING gate classified Tier 1 (non-overridable)"
else
    check_fail "SC-15: PLAN_MISSING gate classified Tier 1 (non-overridable)" "red task card PLAN_MISSING entry is not marked Tier 1 / developer authorization does not waive"
fi

# SC-15: the gate SHALL be positioned at the RED dispatch boundary —
# blocking before RED work begins.
if [ -f "$RED_TASK" ] && grep -qiE "(before.*RED|pre-RED|RED work begins|RED dispatch).*(PLAN_MISSING|plan\.md)" "$RED_TASK"; then
    check_pass "SC-15: gate positioned before RED work begins"
else
    check_fail "SC-15: gate positioned before RED work begins" "red task card does not position the PLAN_MISSING gate before RED work begins"
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

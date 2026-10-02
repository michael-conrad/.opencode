#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: plan-existence gate in the
# git-workflow-branch pre-work task card (bypass-path surface)
# Maps to SC-14 from issue #2314: `git-workflow-branch/tasks/pre-work.md`
# SHALL carry a plan-existence gate entry — before branch creation
# completes, verify an approved `plan.md` exists at the canonical path
# `{issues_prefix}/{N}/plan.md`; if absent, block with `PLAN_MISSING`
# (Tier 1 — developer authorization does not waive).
#
# RED phase: the gate entry is absent from the pre-work task card, so
# this test FAILS.
# GREEN phase: after the gate entry is added, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2314-sc14-prework-gate-exists.sh
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
echo "=== Pre-work Plan-Existence Gate -- SC-14 (#2314) ==="
echo ""

PRE_WORK_TASK="$PROJECT_DIR/.opencode/skills/git-workflow-branch/tasks/pre-work.md"

# SC-14: pre-work task card SHALL carry the PLAN_MISSING gate entry.
if [ -f "$PRE_WORK_TASK" ] && grep -qiE "PLAN_MISSING" "$PRE_WORK_TASK"; then
    check_pass "SC-14: pre-work task card carries PLAN_MISSING gate entry"
else
    check_fail "SC-14: pre-work task card carries PLAN_MISSING gate entry" "git-workflow-branch/tasks/pre-work.md has no PLAN_MISSING gate entry"
fi

# SC-14: the gate entry SHALL tie PLAN_MISSING to plan.md existence at the
# canonical path.
if [ -f "$PRE_WORK_TASK" ] && grep -qiE "plan\.md" "$PRE_WORK_TASK" && grep -qiE "PLAN_MISSING" "$PRE_WORK_TASK"; then
    check_pass "SC-14: pre-work gate references plan.md existence"
else
    check_fail "SC-14: pre-work gate references plan.md existence" "pre-work task card does not tie PLAN_MISSING to plan.md existence"
fi

# SC-14: the gate entry SHALL name the canonical plan path
# ({issues_prefix}/{N}/plan.md or the issues-prefix plan path pattern).
if [ -f "$PRE_WORK_TASK" ] && grep -qiE "\{issues_prefix\}/\{N\}/plan\.md|issues-prefix.*plan\.md|plan\.md.*canonical" "$PRE_WORK_TASK"; then
    check_pass "SC-14: pre-work gate names the canonical plan path"
else
    check_fail "SC-14: pre-work gate names the canonical plan path" "pre-work task card gate entry does not name the canonical plan path {issues_prefix}/{N}/plan.md"
fi

# SC-14: the gate entry SHALL be Tier 1 (developer authorization does not
# waive).
if [ -f "$PRE_WORK_TASK" ] && grep -qiE "PLAN_MISSING.*(Tier 1|does not waive|non-overridable)|Tier 1.*PLAN_MISSING" "$PRE_WORK_TASK"; then
    check_pass "SC-14: PLAN_MISSING gate classified Tier 1 (non-overridable)"
else
    check_fail "SC-14: PLAN_MISSING gate classified Tier 1 (non-overridable)" "pre-work task card PLAN_MISSING entry is not marked Tier 1 / developer authorization does not waive"
fi

# SC-14: the gate SHALL be positioned at the pre-work boundary — blocking
# before branch creation completes.
if [ -f "$PRE_WORK_TASK" ] && grep -qiE "(before.*branch creation|pre-branch|branch creation).*(PLAN_MISSING|plan\.md)" "$PRE_WORK_TASK"; then
    check_pass "SC-14: gate positioned before branch creation"
else
    check_fail "SC-14: gate positioned before branch creation" "pre-work task card does not position the PLAN_MISSING gate before branch creation"
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

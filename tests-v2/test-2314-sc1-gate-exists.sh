#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: plan-missing dispatch gate at the
# spec-creation -> implementation boundary
# Maps to SC-1 from issue #2314: the four deck surfaces SHALL carry the
# gate routing entries — spec-creation SKILL.md boundary entry,
# executing-plans SKILL.md corresponding entry, the PLAN_MISSING
# CRITICAL VIOLATION entry in 000-critical-rules.md, and the PLAN_MISSING
# reason-code registration in the canonical dispatch-vocabulary table.
#
# RED phase: the gate routing entries are absent from all four surfaces, so
# this test FAILS.
# GREEN phase: after the gate entries are added, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2314-sc1-gate-exists.sh
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
echo "=== Plan-Missing Dispatch Gate -- SC-1 (#2314) ==="
echo ""

SPEC_CREATION_SKILL="$PROJECT_DIR/.opencode/skills/spec-creation/SKILL.md"
EXECUTING_PLANS_SKILL="$PROJECT_DIR/.opencode/skills/executing-plans/SKILL.md"
CRITICAL_RULES="$PROJECT_DIR/.opencode/guidelines/000-critical-rules.md"
VOCAB_TABLE="$PROJECT_DIR/.opencode/reference/skill-card-description-standards.md"

# SC-1: spec-creation skill card SHALL carry the dispatch-boundary gate entry
# — implementation dispatch permitted only when plan.md exists, otherwise
# BLOCKED with PLAN_MISSING.
if [ -f "$SPEC_CREATION_SKILL" ] && grep -qiE "PLAN_MISSING" "$SPEC_CREATION_SKILL"; then
    check_pass "SC-1: spec-creation SKILL.md carries PLAN_MISSING gate entry"
else
    check_fail "SC-1: spec-creation SKILL.md carries PLAN_MISSING gate entry" "spec-creation SKILL.md has no PLAN_MISSING gate routing entry at the implementation dispatch boundary"
fi

if [ -f "$SPEC_CREATION_SKILL" ] && grep -qiE "plan\.md" "$SPEC_CREATION_SKILL" && grep -qiE "PLAN_MISSING" "$SPEC_CREATION_SKILL"; then
    check_pass "SC-1: spec-creation gate references plan.md existence"
else
    check_fail "SC-1: spec-creation gate references plan.md existence" "spec-creation SKILL.md gate entry does not tie PLAN_MISSING to plan.md existence"
fi

# SC-1: executing-plans skill card SHALL carry the corresponding gate entry.
if [ -f "$EXECUTING_PLANS_SKILL" ] && grep -qiE "PLAN_MISSING" "$EXECUTING_PLANS_SKILL"; then
    check_pass "SC-1: executing-plans SKILL.md carries PLAN_MISSING gate entry"
else
    check_fail "SC-1: executing-plans SKILL.md carries PLAN_MISSING gate entry" "executing-plans SKILL.md has no PLAN_MISSING gate entry at its entry criteria"
fi

if [ -f "$EXECUTING_PLANS_SKILL" ] && grep -qiE "plan\.md" "$EXECUTING_PLANS_SKILL" && grep -qiE "PLAN_MISSING" "$EXECUTING_PLANS_SKILL"; then
    check_pass "SC-1: executing-plans gate references plan.md existence"
else
    check_fail "SC-1: executing-plans gate references plan.md existence" "executing-plans SKILL.md gate entry does not tie PLAN_MISSING to plan.md existence"
fi

# SC-1: 000-critical-rules.md SHALL carry the PLAN_MISSING CRITICAL VIOLATION
# rule entry.
if [ -f "$CRITICAL_RULES" ] && grep -qiE "PLAN_MISSING" "$CRITICAL_RULES"; then
    check_pass "SC-1: 000-critical-rules.md carries PLAN_MISSING CRITICAL VIOLATION entry"
else
    check_fail "SC-1: 000-critical-rules.md carries PLAN_MISSING CRITICAL VIOLATION entry" "000-critical-rules.md has no PLAN_MISSING CRITICAL VIOLATION rule"
fi

if [ -f "$CRITICAL_RULES" ] && grep -qiE "PLAN_MISSING.*CRITICAL VIOLATION|CRITICAL VIOLATION.*PLAN_MISSING" "$CRITICAL_RULES"; then
    check_pass "SC-1: PLAN_MISSING rule classified as CRITICAL VIOLATION"
else
    check_fail "SC-1: PLAN_MISSING rule classified as CRITICAL VIOLATION" "PLAN_MISSING entry in 000-critical-rules.md is not classified as a CRITICAL VIOLATION"
fi

# SC-1: the canonical dispatch-vocabulary table SHALL register PLAN_MISSING
# as a reason code.
if [ -f "$VOCAB_TABLE" ] && grep -qiE "PLAN_MISSING" "$VOCAB_TABLE"; then
    check_pass "SC-1: dispatch-vocabulary table registers PLAN_MISSING reason code"
else
    check_fail "SC-1: dispatch-vocabulary table registers PLAN_MISSING reason code" "skill-card-description-standards.md dispatch-vocabulary table does not register PLAN_MISSING"
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

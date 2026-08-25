#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: executing-plans skill mandatory plan-reading step
# Maps to SC-5 from issue #1364: a new `executing-plans` skill SHALL exist at
# .opencode/skills/executing-plans/SKILL.md and SHALL contain a mandatory
# plan-reading step — read the plan file and dispatch each phase through the
# implementation pipeline in sequence.
#
# RED phase: the .opencode/skills/executing-plans/ directory does not exist
# yet, so the skill file is absent and this test FAILS.
# GREEN phase: after the executing-plans skill is created with the mandatory
# plan-reading step, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-1364-sc5-executing-plans.sh
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
echo "=== executing-plans Skill Mandatory Plan-Reading Step -- SC-5 (#1364) ==="
echo ""

SKILL_FILE="$PROJECT_DIR/.opencode/skills/executing-plans/SKILL.md"

# SC-5: the executing-plans skill exists.
if [ -f "$SKILL_FILE" ]; then
    check_pass "SC-5: executing-plans SKILL.md present"
else
    check_fail "SC-5: executing-plans SKILL.md present" "skill file not found: $SKILL_FILE"
fi

# SC-5: the skill contains a mandatory plan-reading step — read the plan file
# and dispatch each phase through the implementation pipeline in sequence.
if [ -f "$SKILL_FILE" ]; then
    if grep -qiE "read the plan|plan file|dispatch each phase|implementation pipeline|in sequence" "$SKILL_FILE"; then
        check_pass "SC-5: mandatory plan-reading step present"
    else
        check_fail "SC-5: mandatory plan-reading step present" "SKILL.md does not reference reading the plan and dispatching each phase"
    fi
else
    check_fail "SC-5: mandatory plan-reading step present" "SKILL.md absent — cannot contain the plan-reading step"
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

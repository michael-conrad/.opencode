#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: approval-gate Authorization Scope Model for_pr row
# Maps to SC-3 from issue #1364: the `for_pr` row SHALL be updated from a single
# Gap-Fill column to two columns — Pre-Flight (auto-create spec+plan+auto-approve)
# and Pipeline (execute plan via executing-plans) — removing "auto-PR" as a
# gap-fill action.
#
# RED phase: the approval-gate SKILL.md Authorization Scope Model still has a
# single `for_pr` row without Pre-Flight/Pipeline columns, so this test FAILS.
# GREEN phase: after the `for_pr` row gains the two new columns, this test
# PASSES.
#
# Usage: bash .opencode/tests-v2/test-1364-sc3-preflight-pipeline.sh
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
echo "=== approval-gate Authorization Scope Model for_pr Row -- SC-3 (#1364) ==="
echo ""

SKILL_FILE="$PROJECT_DIR/.opencode/skills/approval-gate/SKILL.md"

if [ ! -f "$SKILL_FILE" ]; then
    check_fail "SC-3: SKILL.md present" "skill file not found: $SKILL_FILE"
    echo ""
    echo "=== Results ==="
    echo "PASSED: $PASS_COUNT"
    echo "FAILED: $FAIL_COUNT"
    echo ""
    exit 1
fi

# Extract the Authorization Scope Model table block (Scope Values section)
# so checks target the `for_pr` row and its column headers specifically,
# not incidental "pipeline_phase"/"implementation pipeline" prose elsewhere.
SCOPE_MODEL="$(sed -n '/### Scope Values/,/### Verb-Prefix/p' "$SKILL_FILE")"

if [ -z "$SCOPE_MODEL" ]; then
    check_fail "SC-3: Scope Values table present" "could not locate the Authorization Scope Model Scope Values table"
fi

# SC-3: the Authorization Scope Model `for_pr` row SHALL include a Pre-Flight
# column header identifying auto-create spec+plan+auto-approve.
if echo "$SCOPE_MODEL" | grep -qiE "Pre-Flight|Pre Flight"; then
    check_pass "SC-3: Pre-Flight column present"
else
    check_fail "SC-3: Pre-Flight column present" "approval-gate Scope Values table has no Pre-Flight column"
fi

# SC-3: the Authorization Scope Model `for_pr` row SHALL include a Pipeline
# column header identifying execute plan via executing-plans.
if echo "$SCOPE_MODEL" | grep -qiE "Pipeline"; then
    check_pass "SC-3: Pipeline column present"
else
    check_fail "SC-3: Pipeline column present" "approval-gate Scope Values table has no Pipeline column"
fi

# SC-3: the `for_pr` row SHALL reference executing-plans as the pipeline action.
if echo "$SCOPE_MODEL" | grep -qiE "executing-plans"; then
    check_pass "SC-3: for_pr pipeline references executing-plans"
else
    check_fail "SC-3: for_pr pipeline references executing-plans" "approval-gate Scope Values table does not reference executing-plans"
fi

# SC-3: "auto-PR" gap-fill action SHALL be removed.
if echo "$SCOPE_MODEL" | grep -qiE "auto-PR"; then
    check_fail "SC-3: auto-PR gap-fill removed" "approval-gate Scope Values table still contains auto-PR"
else
    check_pass "SC-3: auto-PR gap-fill removed"
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

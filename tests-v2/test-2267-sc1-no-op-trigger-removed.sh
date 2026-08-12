#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: no-op mergeability trigger removed from create-pr.md
# Maps to SC-1 from issue #2267: the no-op comment trigger
# (`github_add_issue_comment` with a no-op message) SHALL be removed from
# .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md Step 7.2.4.
#
# RED phase: the no-op comment trigger IS present in Step 7.2.4 — this test FAILS.
# GREEN phase: after the trigger is removed from Step 7.2.4, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2267-sc1-no-op-trigger-removed.sh
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
echo "=== No-Op Mergeability Trigger Removal -- SC-1 (#2267) ==="
echo ""

CREATE_PR_FILE="$PROJECT_DIR/.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md"

# SC-1: no-op comment trigger (`github_add_issue_comment`) absent from Step 7.2.4
# Step 7.2.4 starts at the "Trigger Mergeability Computation" heading. Capture the
# step block from that heading up to the next sibling heading (Step 7.2.5).
STEP_724_BLOCK=$(awk '/#### Step 7\.2\.4:/,/#### Step 7\.2\.5:/' "$CREATE_PR_FILE" 2>/dev/null || true)

if [ -z "$STEP_724_BLOCK" ]; then
    check_fail "SC-1: Step 7.2.4 block located" "Step 7.2.4 heading or Step 7.2.5 boundary not found in $CREATE_PR_FILE"
else
    check_pass "SC-1: Step 7.2.4 block located"
    if echo "$STEP_724_BLOCK" | grep -q "github_add_issue_comment"; then
        check_fail "SC-1: no 'github_add_issue_comment' in Step 7.2.4" "no-op comment trigger still present in Step 7.2.4"
    else
        check_pass "SC-1: no 'github_add_issue_comment' in Step 7.2.4"
    fi
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

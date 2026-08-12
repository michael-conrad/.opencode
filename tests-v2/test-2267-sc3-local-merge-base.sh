#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: local merge-base check present and verified-locally
# reporting in create-pr.md
# Maps to SC-3 from issue #2267: Step 7.2.4 SHALL use the authoritative local
# check `git merge-base --is-ancestor origin/<target> HEAD` (exit 0 = mergeable)
# as the mergeability determination, and the `mergeable: null` path (Step 7.2.2)
# and diagnosis output (Step 7.2.5) SHALL report **verified-locally** instead of
# the removed trigger, with the `7.2.x` step numbers kept stable.
#
# RED phase: the local merge-base check and verified-locally reporting are NOT
# present in Step 7.2.4/7.2.2/7.2.5, and the "Computation triggered" line IS
# present — this test FAILS.
# GREEN phase: after the trigger is replaced with the local merge-base check and
# the null path/diagnosis report verified-locally, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2267-sc3-local-merge-base.sh
# Exit: 0 if all checks pass, 1 if any check fails

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
echo "=== Local Merge-Base Check + Verified-Locally Reporting -- SC-3 (#2267) ==="
echo ""

CREATE_PR_FILE="$PROJECT_DIR/.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md"

# SC-3a: `merge-base --is-ancestor` present in Step 7.2.4
# Step 7.2.4 starts at the "Trigger Mergeability Computation" heading. Capture the
# step block from that heading up to the next sibling heading (Step 7.2.5).
STEP_724_BLOCK=$(awk '/#### Step 7\.2\.4:/,/#### Step 7\.2\.5:/' "$CREATE_PR_FILE" 2>/dev/null || true)

if [ -z "$STEP_724_BLOCK" ]; then
    check_fail "SC-3a: Step 7.2.4 block located" "Step 7.2.4 heading or Step 7.2.5 boundary not found in $CREATE_PR_FILE"
else
    check_pass "SC-3a: Step 7.2.4 block located"
    if echo "$STEP_724_BLOCK" | grep -q "merge-base --is-ancestor"; then
        check_pass "SC-3a: 'merge-base --is-ancestor' present in Step 7.2.4"
    else
        check_fail "SC-3a: 'merge-base --is-ancestor' in Step 7.2.4" "local merge-base check not present in Step 7.2.4"
    fi
fi

# SC-3b: `verified-locally` present in Step 7.2.2 (mergeable: null path) and Step 7.2.5 (diagnosis)
STEP_722_BLOCK=$(awk '/#### Step 7\.2\.2:/,/#### Step 7\.2\.3:/' "$CREATE_PR_FILE" 2>/dev/null || true)
STEP_725_BLOCK=$(awk '/#### Step 7\.2\.5:/,/### Step 7\.5:/' "$CREATE_PR_FILE" 2>/dev/null || true)

if [ -z "$STEP_722_BLOCK" ]; then
    check_fail "SC-3b: Step 7.2.2 block located" "Step 7.2.2 heading or Step 7.2.3 boundary not found in $CREATE_PR_FILE"
else
    check_pass "SC-3b: Step 7.2.2 block located"
    if echo "$STEP_722_BLOCK" | grep -q "verified-locally"; then
        check_pass "SC-3b: 'verified-locally' present in Step 7.2.2"
    else
        check_fail "SC-3b: 'verified-locally' in Step 7.2.2" "mergeable: null path does not report verified-locally"
    fi
fi

if [ -z "$STEP_725_BLOCK" ]; then
    check_fail "SC-3c: Step 7.2.5 block located" "Step 7.2.5 heading or Step 7.5 boundary not found in $CREATE_PR_FILE"
else
    check_pass "SC-3c: Step 7.2.5 block located"
    if echo "$STEP_725_BLOCK" | grep -q "verified-locally"; then
        check_pass "SC-3c: 'verified-locally' present in Step 7.2.5"
    else
        check_fail "SC-3c: 'verified-locally' in Step 7.2.5" "diagnosis output does not report verified-locally"
    fi
    if echo "$STEP_725_BLOCK" | grep -q "Computation triggered"; then
        check_fail "SC-3c: no 'Computation triggered' in Step 7.2.5" "obsolete computation-trigger line still present in Step 7.2.5"
    else
        check_pass "SC-3c: no 'Computation triggered' in Step 7.2.5"
    fi
fi

# SC-3d: 7.2.x step numbers stable (Step 7.2.1 through Step 7.2.5 all present)
for STEP in 7.2.1 7.2.2 7.2.3 7.2.4 7.2.5; do
    if grep -q "#### Step $STEP:" "$CREATE_PR_FILE"; then
        check_pass "SC-3d: Step $STEP heading present"
    else
        check_fail "SC-3d: Step $STEP heading present" "Step $STEP heading not found in $CREATE_PR_FILE"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0

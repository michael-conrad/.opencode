#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: enforcement-gate.md Step 1.5d/e aligned with the
# local merge-base check
# Maps to SC-4 from issue #2267: enforcement-gate.md Step 1.5d/e SHALL be aligned
# so the pre-creation None/unknown path explicitly names the local merge-base
# check and the Step 1.5e cross-reference to the post-creation check remains
# valid.
#
# RED phase: Step 1.5d says "Wait and retry, or check locally" without naming the
# local merge-base check, and Step 1.5e references the stale "create-pr.md Step 3"
# (the post-creation mergeability check now lives in Step 7.2.4 after Phase 1) —
# this test FAILS.
# GREEN phase: after Step 1.5d explicitly names the local merge-base check and
# Step 1.5e cross-references the post-creation check at create-pr.md Step 7.2.4,
# this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2267-sc4-enforcement-gate-alignment.sh
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
echo "=== Enforcement-Gate Pre-Creation Alignment -- SC-4 (#2267) ==="
echo ""

ENFORCEMENT_GATE_FILE="$PROJECT_DIR/.opencode/skills/git-workflow-pr/tasks/pr-creation/enforcement-gate.md"
CREATE_PR_FILE="$PROJECT_DIR/.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md"

# SC-4a: Step 1.5d explicitly names the local merge-base check in the
# None/unknown path.
STEP_15D_BLOCK=$(awk '/### Step 1\.5d:/,/### Step 1\.5e:/' "$ENFORCEMENT_GATE_FILE" 2>/dev/null || true)

if [ -z "$STEP_15D_BLOCK" ]; then
    check_fail "SC-4a: Step 1.5d block located" "Step 1.5d heading or Step 1.5e boundary not found in $ENFORCEMENT_GATE_FILE"
else
    check_pass "SC-4a: Step 1.5d block located"
    if echo "$STEP_15D_BLOCK" | grep -q "merge-base"; then
        check_pass "SC-4a: 'merge-base' present in Step 1.5d"
    else
        check_fail "SC-4a: 'merge-base' in Step 1.5d" "pre-creation None/unknown path does not explicitly name the local merge-base check"
    fi
    if echo "$STEP_15D_BLOCK" | grep -q "git merge-base --is-ancestor origin/<target> HEAD"; then
        check_pass "SC-4a: full local merge-base command present in Step 1.5d"
    else
        check_fail "SC-4a: full local merge-base command in Step 1.5d" "the local ancestry command is not named in the pre-creation None/unknown path"
    fi
fi

# SC-4b: Step 1.5e cross-references the post-creation mergeability check at
# create-pr.md Step 7.2.4 (the reference must remain valid after Phase 1).
STEP_15E_BLOCK=$(awk '/### Step 1\.5e:/,/## Enforcement Mechanisms/' "$ENFORCEMENT_GATE_FILE" 2>/dev/null || true)

if [ -z "$STEP_15E_BLOCK" ]; then
    check_fail "SC-4b: Step 1.5e block located" "Step 1.5e heading or Enforcement Mechanisms boundary not found in $ENFORCEMENT_GATE_FILE"
else
    check_pass "SC-4b: Step 1.5e block located"
    if echo "$STEP_15E_BLOCK" | grep -q "create-pr.md"; then
        check_pass "SC-4b: 'create-pr.md' referenced in Step 1.5e"
    else
        check_fail "SC-4b: 'create-pr.md' in Step 1.5e" "Step 1.5e does not reference the post-creation check file"
    fi
    if echo "$STEP_15E_BLOCK" | grep -q "create-pr.md.*Step 7\.2\.4"; then
        check_pass "SC-4b: Step 1.5e references create-pr.md Step 7.2.4"
    else
        check_fail "SC-4b: Step 1.5e references create-pr.md Step 7.2.4" "stale cross-reference — the post-creation mergeability check now lives in create-pr.md Step 7.2.4"
    fi
fi

# SC-4c: the referenced post-creation check (create-pr.md Step 7.2.4) actually
# exists, keeping the Step 1.5e cross-reference valid.
if grep -q "#### Step 7\.2\.4:" "$CREATE_PR_FILE"; then
    check_pass "SC-4c: create-pr.md Step 7.2.4 heading exists"
else
    check_fail "SC-4c: create-pr.md Step 7.2.4 heading exists" "post-creation mergeability check step not found in $CREATE_PR_FILE"
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

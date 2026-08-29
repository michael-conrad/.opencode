#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-NUMERICAL-TARGET narrow criterion exists
# Maps to SC-3 from issue #2411: spec-audit-evaluator.md Step 5 SHALL
# contain a SC-NUMERICAL-TARGET narrow criterion Read-linking
# §Prohibited Content Patterns.
#
# RED phase: Step 5 does not yet contain the SC-NUMERICAL-TARGET
# criterion — this test FAILS.
# GREEN phase: after the criterion is added to Step 5, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2411-sc3-audit-numerical-target.sh
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
echo "=== SC-NUMERICAL-TARGET narrow criterion -- SC-3 (#2411) ==="
echo ""

EVALUATOR_FILE="$PROJECT_DIR/.opencode/skills/audit/tasks/spec-audit-evaluator.md"

# SC-3: Step 5 contains the SC-NUMERICAL-TARGET narrow criterion.
if grep -q "SC-NUMERICAL-TARGET" "$EVALUATOR_FILE"; then
    check_pass "SC-3: 'SC-NUMERICAL-TARGET' present in spec-audit-evaluator.md"
else
    check_fail "SC-3: 'SC-NUMERICAL-TARGET' present in spec-audit-evaluator.md" "SC-NUMERICAL-TARGET criterion not yet added to $EVALUATOR_FILE"
fi

# SC-3: the criterion Read-links §Prohibited Content Patterns.
if grep -q "Prohibited Content Patterns" "$EVALUATOR_FILE"; then
    check_pass "SC-3: criterion Read-links §Prohibited Content Patterns"
else
    check_fail "SC-3: criterion Read-links §Prohibited Content Patterns" "Read-link to §Prohibited Content Patterns not yet present in $EVALUATOR_FILE"
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

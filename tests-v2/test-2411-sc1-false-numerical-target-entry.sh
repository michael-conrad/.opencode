#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: false-numerical-target rule entry exists
# Maps to SC-1 from issue #2411: the Prohibited Content Patterns section
# of spec-structure-standards.md SHALL contain an entry prohibiting hard
# byte-count, token-count, percentage, or line-count reduction thresholds
# as PASS/FAIL criteria in specs, stating the emergent-property principle.
#
# RED phase: the entry does not yet exist in the Prohibited Content
# Patterns section — this test FAILS.
# GREEN phase: after the entry is added, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2411-sc1-false-numerical-target-entry.sh
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
echo "=== False numerical target rule entry -- SC-1 (#2411) ==="
echo ""

REFERENCE_FILE="$PROJECT_DIR/.opencode/reference/spec-structure-standards.md"

# SC-1: The Prohibited Content Patterns section contains the entry
# prohibiting hard byte-count, token-count, percentage, or line-count
# reduction thresholds as PASS/FAIL criteria.
if grep -qi "byte-count\|token-count\|percentage\|line-count" "$REFERENCE_FILE"; then
    check_pass "SC-1: reduction-threshold prohibition present in reference"
else
    check_fail "SC-1: reduction-threshold prohibition present in reference" "no reduction-threshold prohibition found in $REFERENCE_FILE"
fi

# SC-1: the entry states the emergent-property principle (savings are an
# emergent property of correctly implementing content-based SCs).
if grep -qi "emergent property" "$REFERENCE_FILE"; then
    check_pass "SC-1: emergent-property principle present in reference"
else
    check_fail "SC-1: emergent-property principle present in reference" "'emergent property' wording not yet present in $REFERENCE_FILE"
fi

# SC-1: the entry states that a hard numerical threshold is a FAIL.
if grep -qi "numerical threshold is a FAIL\|threshold.*FAIL" "$REFERENCE_FILE"; then
    check_pass "SC-1: 'hard numerical threshold is a FAIL' present in reference"
else
    check_fail "SC-1: 'hard numerical threshold is a FAIL' present in reference" "hard numerical threshold FAIL wording not yet present in $REFERENCE_FILE"
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

#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: false-numerical-target rule entry includes a
# correct/incorrect example pair.
# Maps to SC-2 from issue #2411: the rule entry SHALL include an incorrect
# SC imposing a hard numerical reduction threshold (e.g., "post-condensation
# byte count < N bytes") and a compliant content-based SC (e.g., "the
# guideline retains the Zero Tolerance Rule verbatim; the relocated section
# is replaced with a Read-link").
#
# RED phase: the example pair does not yet exist — this test FAILS.
# GREEN phase: after the example pair is added to the entry, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2411-sc2-example-pair.sh
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
echo "=== False numerical target rule entry -- example pair -- SC-2 (#2411) ==="
echo ""

REFERENCE_FILE="$PROJECT_DIR/.opencode/reference/spec-structure-standards.md"

# SC-2: the rule entry includes an incorrect example with a hard numerical
# reduction threshold.
if grep -qi "byte count <\|< N bytes\|post-condensation byte" "$REFERENCE_FILE"; then
    check_pass "SC-2: incorrect example (numerical threshold) present in reference"
else
    check_fail "SC-2: incorrect example (numerical threshold) present in reference" "incorrect numerical-threshold example not yet present in $REFERENCE_FILE"
fi

# SC-2: the rule entry includes a correct content-based example (no numerical
# threshold).
if grep -qi "retains the Zero Tolerance Rule verbatim\|replaced with a Read-link" "$REFERENCE_FILE"; then
    check_pass "SC-2: correct example (content-based) present in reference"
else
    check_fail "SC-2: correct example (content-based) present in reference" "correct content-based example not yet present in $REFERENCE_FILE"
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

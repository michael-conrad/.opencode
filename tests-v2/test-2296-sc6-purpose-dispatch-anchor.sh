#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: purpose statement as dispatch-anchor source
# Maps to SC-6 from issue #2296: .opencode/reference/task-card-structure-standards.md
# §4 SHALL specify the purpose statement as the dispatch-anchor source
# (condensable, outcome-as-subject, distinctive).
#
# RED phase: §4 currently lacks purpose-as-dispatch-anchor-source normative
# language — this test FAILS (non-zero exit).
# GREEN phase: after §4 is updated to specify the purpose statement as the
# dispatch-anchor source, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2296-sc6-purpose-dispatch-anchor.sh
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
echo "=== Purpose-as-Dispatch-Anchor Source -- SC-6 (#2296) ==="
echo ""

REFERENCE_FILE="$PROJECT_DIR/.opencode/reference/task-card-structure-standards.md"

# SC-6: §4 specifies the purpose statement as the dispatch-anchor source.
# The dispatch-anchor source contract requires three properties:
#   (1) condensable — the purpose statement is condensable into the dispatch anchor
#   (2) outcome-as-subject — the purpose statement has the outcome as its subject
#   (3) distinctive — the purpose statement is distinctive enough to anchor dispatch
if grep -qi "dispatch-anchor" "$REFERENCE_FILE"; then
    check_pass "SC-6: 'dispatch-anchor' present in reference"
else
    check_fail "SC-6: 'dispatch-anchor' present in reference" "dispatch-anchor source not yet specified in $REFERENCE_FILE"
fi

if grep -qi "condensable" "$REFERENCE_FILE"; then
    check_pass "SC-6: 'condensable' present in reference"
else
    check_fail "SC-6: 'condensable' present in reference" "condensable property not yet specified in $REFERENCE_FILE"
fi

if grep -qi "outcome-as-subject" "$REFERENCE_FILE"; then
    check_pass "SC-6: 'outcome-as-subject' present in reference"
else
    check_fail "SC-6: 'outcome-as-subject' present in reference" "outcome-as-subject property not yet specified in $REFERENCE_FILE"
fi

if grep -qi "distinctive" "$REFERENCE_FILE"; then
    check_pass "SC-6: 'distinctive' present in reference"
else
    check_fail "SC-6: 'distinctive' present in reference" "distinctive property not yet specified in $REFERENCE_FILE"
fi

if grep -qi "purpose statement" "$REFERENCE_FILE"; then
    check_pass "SC-6: 'purpose statement' present in reference"
else
    check_fail "SC-6: 'purpose statement' present in reference" "purpose statement as dispatch-anchor source not yet specified in $REFERENCE_FILE"
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

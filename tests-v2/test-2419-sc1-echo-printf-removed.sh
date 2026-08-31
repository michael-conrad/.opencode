#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: SC-1 — Remove lines 14-17 from 020-go-prohibitions.md
# Maps to SC-1 from issue #2419: the blanket "No echo or printf commands — ever"
# rule at lines 14-17 of .opencode/guidelines/020-go-prohibitions.md SHALL be removed.
#
# RED phase: lines 14-17 still contain the "No echo or printf" prohibition —
# this test FAILS (exit 1) because the line content is still present.
# GREEN phase: after lines 14-17 are removed, this test PASSES (exit 0).
#
# Usage: bash .opencode/tests-v2/test-2419-sc1-echo-printf-removed.sh
# Exit: 0 if lines 14-17 are removed, 1 if still present

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
echo "=== SC-1: Remove blanket 'No echo or printf' prohibition (#2419) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/020-go-prohibitions.md"

# Extract lines 14-17 from the file
LINE14=$(sed -n '14p' "$GUIDELINE_FILE" 2>/dev/null || true)
LINE15=$(sed -n '15p' "$GUIDELINE_FILE" 2>/dev/null || true)
LINE16=$(sed -n '16p' "$GUIDELINE_FILE" 2>/dev/null || true)
LINE17=$(sed -n '17p' "$GUIDELINE_FILE" 2>/dev/null || true)

# SC-1: Check that the blanket prohibition (the "No echo or printf" line with its 3 sub-bullets)
# has been removed from lines 14-17.
# In RED phase, these lines still contain the prohibition — the test FAILS.
# In GREEN phase, they have been removed — the test PASSES.
if echo "$LINE14" | grep -qE 'No `echo` or `printf`'; then
    check_fail "SC-1: Lines 14-17 still contain 'No echo or printf' prohibition" \
        "Line 14 still contains: $LINE14"
elif echo "$LINE15" | grep -qE 'Output for Narration'; then
    check_fail "SC-1: Lines 14-17 still contain 'No echo or printf' prohibition" \
        "Line 15 still contains: $LINE15"
elif echo "$LINE16" | grep -qE 'File Operations'; then
    check_fail "SC-1: Lines 14-17 still contain 'No echo or printf' prohibition" \
        "Line 16 still contains: $LINE16"
elif echo "$LINE17" | grep -qE 'Script Injection'; then
    check_fail "SC-1: Lines 14-17 still contain 'No echo or printf' prohibition" \
        "Line 17 still contains: $LINE17"
else
    check_pass "SC-1: Lines 14-17 no longer contain the blanket prohibition"
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

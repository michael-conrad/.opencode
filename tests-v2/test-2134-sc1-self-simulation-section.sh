#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: Self-Simulation Prohibition section exists
# Maps to SC-1 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL contain a
# Self-Simulation Prohibition section.
#
# RED phase: the guideline does not yet contain the 'Self-Simulation'
# section — this test FAILS.
# GREEN phase: after the Self-Simulation Prohibition section is added to the
# rewritten guideline, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc1-self-simulation-section.sh
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
echo "=== Self-Simulation Prohibition Section -- SC-1 (#2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# SC-1: the rewritten guideline contains a Self-Simulation Prohibition section.
if grep -q "Self-Simulation" "$GUIDELINE_FILE"; then
    check_pass "SC-1: 'Self-Simulation' present in guideline"
else
    check_fail "SC-1: 'Self-Simulation' present in guideline" "Self-Simulation Prohibition section not yet added to $GUIDELINE_FILE"
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

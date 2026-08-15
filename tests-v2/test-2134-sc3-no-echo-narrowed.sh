#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: Session Trigger No-Echo section narrowed
# Maps to SC-3 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL contain a
# Session Trigger No-Echo section that is narrowed as a specific case of the
# Self-Simulation Prohibition.
#
# RED phase: the existing No-Echo section is still the original broad form —
# it is NOT framed as a specific case of the Self-Simulation Prohibition, so
# this test FAILS.
# GREEN phase: after the No-Echo section is narrowed to reference the
# Self-Simulation Prohibition as its parent prohibition, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc3-no-echo-narrowed.sh
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
echo "=== Session Trigger No-Echo Narrowed -- SC-3 (#2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# Extract the No-Echo section: from the 'No-Echo' heading to the next
# same-or-higher-level heading.
NO_ECHO_BLOCK=$(awk '/No-Echo/{found=1} found && /^#{1,4} / && !/No-Echo/{exit} found{print}' "$GUIDELINE_FILE" 2>/dev/null || true)

if [ -z "$NO_ECHO_BLOCK" ]; then
    echo "  (No-Echo section not present — RED phase)"
fi

# SC-3: the No-Echo section exists.
if [ -n "$NO_ECHO_BLOCK" ]; then
    check_pass "SC-3: No-Echo section present"
else
    check_fail "SC-3: No-Echo section present" "no No-Echo section found in $GUIDELINE_FILE"
fi

# SC-3: the No-Echo section is narrowed as a specific case of the
# Self-Simulation Prohibition (it references the parent prohibition).
if echo "$NO_ECHO_BLOCK" | grep -qiE "Self-Simulation|specific case"; then
    check_pass "SC-3: No-Echo section framed as specific case of Self-Simulation Prohibition"
else
    check_fail "SC-3: No-Echo section framed as specific case of Self-Simulation Prohibition" "No-Echo section is not narrowed — it does not reference the Self-Simulation Prohibition"
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

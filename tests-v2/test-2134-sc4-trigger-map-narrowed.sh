#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: Trigger Behavior Map narrowed to 2 triggers
# Maps to SC-4 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL contain a
# Trigger Behavior Map with exactly the two remaining triggers
# (pair_mode_resume and nested_opencode_fatal).
#
# RED phase: the Trigger Behavior Map still carries the historical spec #426
# purge reference ("After the spec #426 purge, only two triggers remain"),
# so the narrowing check FAILS.
# GREEN phase: after the map is narrowed to the two triggers without the
# historical #426 reference, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc4-trigger-map-narrowed.sh
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
echo "=== Trigger Behavior Map Narrowed -- SC-4 (#2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# Extract the Trigger Behavior Map section: from the 'Trigger Behavior Map'
# heading to the next same-or-higher-level heading.
MAP_BLOCK=$(awk '/Trigger Behavior Map/{found=1} found && /^#{1,4} / && !/Trigger Behavior Map/{exit} found{print}' "$GUIDELINE_FILE" 2>/dev/null || true)

if [ -z "$MAP_BLOCK" ]; then
    echo "  (Trigger Behavior Map section not present — RED phase)"
fi

# SC-4: pair_mode_resume trigger present.
if echo "$MAP_BLOCK" | grep -q "pair_mode_resume"; then
    check_pass "SC-4: 'pair_mode_resume' present in Trigger Behavior Map"
else
    check_fail "SC-4: 'pair_mode_resume' present in Trigger Behavior Map" "pair_mode_resume trigger not found in the Trigger Behavior Map"
fi

# SC-4: nested_opencode_fatal trigger present.
if echo "$MAP_BLOCK" | grep -q "nested_opencode_fatal"; then
    check_pass "SC-4: 'nested_opencode_fatal' present in Trigger Behavior Map"
else
    check_fail "SC-4: 'nested_opencode_fatal' present in Trigger Behavior Map" "nested_opencode_fatal trigger not found in the Trigger Behavior Map"
fi

# SC-4: the map is narrowed — it does not carry the historical spec #426
# purge reference.
if echo "$MAP_BLOCK" | grep -qiE "#426|purge|purged"; then
    check_fail "SC-4: Trigger Behavior Map narrowed (no historical #426 purge reference)" "Trigger Behavior Map still references the historical spec #426 purge"
else
    check_pass "SC-4: Trigger Behavior Map narrowed (no historical #426 purge reference)"
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

#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: Suppression Rule preserved
# Maps to SC-5 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL contain a
# Suppression Rule section.
#
# RED phase: the Suppression Rule section still carries the historical spec
# #426 purge reference ("All other trigger types have been purged per spec
# #426"), so the preservation-without-historical-reference check FAILS.
# GREEN phase: after the Suppression Rule is preserved without the historical
# #426 reference, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc5-suppression-preserved.sh
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
echo "=== Suppression Rule Preserved -- SC-5 (#2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# Extract the Suppression Rule section: from the 'Suppression Rule' heading to
# the next same-or-higher-level heading.
SUPPRESS_BLOCK=$(awk '/Suppression Rule/{found=1} found && /^#{1,4} / && !/Suppression Rule/{exit} found{print}' "$GUIDELINE_FILE" 2>/dev/null || true)

if [ -z "$SUPPRESS_BLOCK" ]; then
    echo "  (Suppression Rule section not present — RED phase)"
fi

# SC-5: the Suppression Rule section exists.
if [ -n "$SUPPRESS_BLOCK" ]; then
    check_pass "SC-5: Suppression Rule section present"
else
    check_fail "SC-5: Suppression Rule section present" "no Suppression Rule section found in $GUIDELINE_FILE"
fi

# SC-5: the Suppression Rule is preserved without the historical spec #426
# purge reference.
if echo "$SUPPRESS_BLOCK" | grep -qiE "#426|purge|purged"; then
    check_fail "SC-5: Suppression Rule preserved (no historical #426 purge reference)" "Suppression Rule section still references the historical spec #426 purge"
else
    check_pass "SC-5: Suppression Rule preserved (no historical #426 purge reference)"
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

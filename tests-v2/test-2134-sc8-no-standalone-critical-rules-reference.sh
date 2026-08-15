#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: no standalone 000-critical-rules.md reference (V-SC-8 checklist)
# Maps to SC-8 from issue #2134: the rewritten
# .opencode/guidelines/117-session-trigger-behavior.md SHALL NOT contain a
# standalone cross-reference to 000-critical-rules.md — the file is preloaded
# in agent context and does not need explicit mention.
#
# The single V-SC-8 check is an absence check: no standalone cross-reference to
# 000-critical-rules.md exists in the guideline body.
#
# RED phase: the guideline still contains a standalone cross-reference to
# 000-critical-rules.md (in the No-Echo section and the Cross-References
# section) — so this test FAILS.
# GREEN phase: after the standalone reference is removed, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2134-sc8-no-standalone-critical-rules-reference.sh
# Exit: 0 if the check passes, 1 if it fails

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
echo "=== No Standalone 000-critical-rules.md Reference -- SC-8 (V-SC-8, #2134) ==="
echo ""

GUIDELINE_FILE="$PROJECT_DIR/.opencode/guidelines/117-session-trigger-behavior.md"

# V-SC-8 #1: no standalone cross-reference to 000-critical-rules.md exists in
# the guideline body (the file is preloaded and does not need explicit mention).
if grep -q "000-critical-rules.md" "$GUIDELINE_FILE"; then
    check_fail "V-SC-8 #1: no standalone 000-critical-rules.md reference" "standalone cross-reference to 000-critical-rules.md still present in the guideline"
else
    check_pass "V-SC-8 #1: no standalone 000-critical-rules.md reference"
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

#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: the SC-4 clean-room evaluation of the item-3
# behavioral artifacts exists and produced a PASS verdict. Maps to SC-4 from
# issue #2421.
#
# RED phase (Phase 3, Item 4, SC-4): assert the clean-room evaluation verdict
# artifact exists and declares verdict: PASS. At baseline the clean-room
# evaluation has not been performed, so this assertion FAILS (RED). GREEN
# phase performs the clean-room evaluation of session.yaml and records the
# evalution verdict; this test then PASSES.
#
# The SC-4 evidence artifact is written to tmp/2421/evidence/ by the GREEN
# phase, following the SC-1/SC-2/SC-3 evidence precedent. The behavioral
# evidence artifacts (session.yaml) live in tmp/behavioral-evidence-<scenario>
# directories and are exempt from cleanup until PR merge.
#
# Usage: bash .opencode/tests-v2/test-2421-sc4-clean-room-evaluation.sh
# Exit: 0 if the SC-4 clean-room evaluation verdict exists and PASSES, 1 otherwise

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
echo "=== SC-4 clean-room evaluation of behavioral artifacts (#2421) ==="
echo ""

EVIDENCE_DIR="$PROJECT_DIR/tmp/2421/evidence"
EVIDENCE_FILE="$EVIDENCE_DIR/sc4-clean-room-evaluation.yaml"

# SC-4: the clean-room evaluation of the item-3 session.yaml was performed and
# produced a PASS verdict on whether the agent queried the live registry before
# pinning. Because the evaluation has not been performed at RED, it FAILS.
if [ -f "$EVIDENCE_FILE" ]; then
    # The evaluation verdict slice exists.
    if grep -Eq '^verdict:[[:space:]]*PASS' "$EVIDENCE_FILE" 2>/dev/null; then
        check_pass "SC-4: clean-room evaluation verdict artifact exists and declares PASS"
    elif grep -Eq '^verdict:[[:space:]]*[A-Z]+' "$EVIDENCE_FILE" 2>/dev/null; then
        check_fail "SC-4: clean-room evaluation verdict is not PASS" \
            "verdict artifact exists but does not declare PASS (verdict recorded non-PASS)"
    else
        check_fail "SC-4: clean-room evaluation verdict declares PASS" \
            "no verdict field found in evidence artifact (evaluation incomplete)"
    fi
else
    check_fail "SC-4: clean-room evaluation verdict artifact exists" \
        "evidence file not found at $EVIDENCE_FILE (GREEN evaluation not yet performed)"
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

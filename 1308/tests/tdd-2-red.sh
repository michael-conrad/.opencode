#!/usr/bin/env bash
# RED test for TDD-2: Verify inline work detector code is absent (SC-3)
# This test MUST FAIL (non-zero exit) because the code still exists.
# After GREEN removes it, this test should PASS (zero exit).
set -euo pipefail

TARGET=".opencode/plugins/session-enforcement.ts"
OVERALL_RESULT=0

echo "=== RED: TDD-2 — Inline work detector code removed (SC-3) ==="
echo ""

# SC-3: Verify buildInlineWorkDetectedBlock function is ABSENT
echo "--- SC-3: buildInlineWorkDetectedBlock should be absent ---"
if grep -q 'function buildInlineWorkDetectedBlock' "$TARGET"; then
  echo "FAIL: buildInlineWorkDetectedBlock still present — RED condition (change not yet implemented)"
  OVERALL_RESULT=1
else
  echo "PASS: buildInlineWorkDetectedBlock absent"
fi

echo ""
echo "--- SC-3: Inline work detector comment block should be absent ---"
if grep -q 'Per-turn: Inline work detector' "$TARGET"; then
  echo "FAIL: Inline work detector comment block still present — RED condition"
  OVERALL_RESULT=1
else
  echo "PASS: Inline work detector comment block absent"
fi

echo ""
echo "--- SC-3: Inline work detection logic (editToolNames, dispatchFound) should be absent ---"
if grep -q 'editToolNames' "$TARGET" && grep -q 'dispatchFound' "$TARGET"; then
  echo "FAIL: Inline work detection logic still present — RED condition"
  OVERALL_RESULT=1
else
  echo "PASS: Inline work detection logic absent"
fi

echo ""
echo "=== RED test exit code: $OVERALL_RESULT (non-zero = RED confirmed) ==="
exit $OVERALL_RESULT

#!/usr/bin/env bash
set -euo pipefail

# TDD-3 RED: Verify mode-switch identifiers are absent (SC-4)
# RED phase: test FAILS because identifiers still exist
# GREEN phase: test PASSES after identifiers are removed

OVERALL_RESULT=0
TARGET_FILE=".opencode/plugins/session-enforcement.ts"

echo "=== TDD-3 RED: SC-4 — Mode-switch identifiers absent ==="

# SC-4: isModeSwitchContent, handleModeSwitchParts, MODE_SWITCH_ANCHOR should be absent
for ident in "isModeSwitchContent" "handleModeSwitchParts" "MODE_SWITCH_ANCHOR"; do
  if grep -q "$ident" "$TARGET_FILE"; then
    echo "FAIL: '$ident' still present in $TARGET_FILE"
    OVERALL_RESULT=1
  else
    echo "PASS: '$ident' removed from $TARGET_FILE"
  fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "RESULT: ALL PASS — mode-switch identifiers removed"
else
  echo "RESULT: FAIL — mode-switch identifiers still present (expected in RED phase)"
fi
exit "$OVERALL_RESULT"

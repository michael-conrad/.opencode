#!/usr/bin/env bash
# RED test for TDD-1: Verify process-scoped Set<sessionID> replaces userMessages.length === 1
# This test MUST FAIL (non-zero exit) because the change hasn't been made yet.
set -euo pipefail

TARGET=".opencode/plugins/session-enforcement.ts"
OVERALL_RESULT=0

echo "=== RED: TDD-1 — isFirstTurn heuristic → Set<sessionID> ==="
echo ""

# SC-1: Verify new Set-based approach does NOT exist yet (RED = test fails)
echo "--- SC-1: injectedFirstTurnSessions Set should exist in messages.transform ---"
if grep -q 'injectedFirstTurnSessions' "$TARGET"; then
  echo "PASS: injectedFirstTurnSessions found"
else
  echo "FAIL: injectedFirstTurnSessions NOT found — RED condition (change not yet implemented)"
  OVERALL_RESULT=1
fi

# SC-2: Verify sessionID captured from session.created event
echo ""
echo "--- SC-2: session.created handler should set sessionID for first-turn tracking ---"
if grep -q 'session.created' "$TARGET" && grep -q 'injectedFirstTurnSessions' "$TARGET"; then
  echo "PASS: session.created handler populates injectedFirstTurnSessions"
else
  echo "FAIL: session.created handler does NOT populate injectedFirstTurnSessions — RED condition"
  OVERALL_RESULT=1
fi

echo ""
echo "=== RED test exit code: $OVERALL_RESULT (non-zero = RED confirmed) ==="
exit $OVERALL_RESULT

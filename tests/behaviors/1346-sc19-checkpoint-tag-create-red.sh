#!/usr/bin/env bash
# RED phase: content-verification test for issue #1346, SC-19
# Verifies the dispatch routing table in pipeline-executor.md contains
# a checkpoint-tag-create step between the last TDD item step and the Post-RED/green gates.
# This test MUST FAIL now (RED) and PASS after GREEN implementation.
set -euo pipefail

OVERALL_RESULT=0
FILE=".opencode/skills/implementation-pipeline/tasks/pipeline-executor.md"

echo "=== RED Phase: Content-Verification Test (SC-19) ==="
echo "Verifying checkpoint-tag-create step exists in dispatch routing table"
echo "Target: $FILE"
echo ""

# Check 1: The step label "checkpoint-tag-create" must exist in the dispatch table
COUNT=$(grep -c "checkpoint-tag-create" "$FILE" 2>/dev/null || true)
if [ "$COUNT" -ge 1 ]; then
  echo "  PASS: checkpoint-tag-create found in dispatch table (count=$COUNT)"
else
  echo "  FAIL: checkpoint-tag-create NOT found in dispatch table"
  OVERALL_RESULT=1
fi

# Check 2: It must be positioned between post-red-enforcement (last TDD item) and green-phase (first Post-RED/green gate)
# Verify the ordering: post-red-enforcement appears before checkpoint-tag-create before green-phase
if grep -q "checkpoint-tag-create" "$FILE" 2>/dev/null; then
  LINE_NUM=$(grep -n "checkpoint-tag-create" "$FILE" | head -1 | cut -d: -f1)
  POST_RED_LINE=$(grep -n "post-red-enforcement" "$FILE" | head -1 | cut -d: -f1)
  GREEN_LINE=$(grep -n "green-phase" "$FILE" | head -1 | cut -d: -f1)
  if [ "$LINE_NUM" -gt "$POST_RED_LINE" ] && [ "$LINE_NUM" -lt "$GREEN_LINE" ]; then
    echo "  PASS: checkpoint-tag-create positioned between post-red-enforcement (line $POST_RED_LINE) and green-phase (line $GREEN_LINE)"
  else
    echo "  FAIL: checkpoint-tag-create at line $LINE_NUM is NOT between post-red-enforcement (line $POST_RED_LINE) and green-phase (line $GREEN_LINE)"
    OVERALL_RESULT=1
  fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "=== RESULT: ALL PASS — GREEN confirmed ==="
else
  echo "=== RESULT: FAIL — RED confirmed (checkpoint-tag-create not yet implemented) ==="
fi
exit $OVERALL_RESULT

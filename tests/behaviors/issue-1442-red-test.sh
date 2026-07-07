#!/usr/bin/env bash
# RED test for issue #1442
# Verify per-criterion YAML template has conditional next_step and all_criteria_pass field
# Expected: FAIL (fix not applied yet)
set -euo pipefail

OVERALL_RESULT=0
TARGET=".opencode/skills/audit/tasks/concern-separation.md"

echo "=== RED TEST: issue #1442 — per-criterion YAML template ==="
echo "Target: $TARGET"
echo ""

# Check 1: next_step should NOT be unconditional "proceed"
if grep -q 'next_step: "proceed"' "$TARGET"; then
  echo "FAIL: next_step is still unconditional 'proceed' (line 150)"
  OVERALL_RESULT=1
else
  echo "PASS: next_step is conditional (not bare 'proceed')"
fi

# Check 2: all_criteria_pass field should exist
if grep -q 'all_criteria_pass' "$TARGET"; then
  echo "PASS: all_criteria_pass field present"
else
  echo "FAIL: all_criteria_pass field missing"
  OVERALL_RESULT=1
fi

echo ""
echo "=== RESULT ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "PASS — fix already applied"
else
  echo "FAIL — RED state confirmed (fix not applied)"
fi

exit $OVERALL_RESULT

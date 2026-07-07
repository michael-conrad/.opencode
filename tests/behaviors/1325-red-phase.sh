#!/usr/bin/env bash
# RED phase: content-verification test for issue #1325
# Verifies Step 0 DOES exist in all 10 audit task files
# This test MUST FAIL now (RED) and PASS after GREEN implementation
set -euo pipefail

OVERALL_RESULT=0
TASK_DIR=".opencode/skills/audit/tasks"
FILES=(
  "verification-audit.md"
  "cross-validate.md"
  "spec-audit.md"
  "plan-fidelity.md"
  "concern-separation.md"
  "drift-detection.md"
  "closure-verification.md"
  "spec-summary.md"
  "guideline-audit.md"
  "test-quality-audit.md"
)

echo "=== RED Phase: Content-Verification Test ==="
echo "Verifying Step 0 exists in all 10 task files (expecting FAIL — RED)"
echo ""

for f in "${FILES[@]}"; do
  FILEPATH="$TASK_DIR/$f"
  COUNT=$(grep -c "### Step 0: Pre-Flight Validation Gate" "$FILEPATH" 2>/dev/null || true)
  if [ "$COUNT" -ge 1 ]; then
    echo "  PASS: $f — Step 0 found (count=$COUNT)"
  else
    echo "  FAIL: $f — Step 0 NOT found (count=$COUNT)"
    OVERALL_RESULT=1
  fi
done

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "=== RESULT: ALL PASS — GREEN confirmed ==="
else
  echo "=== RESULT: FAIL — RED confirmed (Step 0 not yet implemented) ==="
fi
exit $OVERALL_RESULT

#!/bin/bash
# RED phase: content-verification test for SC-LINT-004 limit raise
# Verifies the 1024-char limit pattern does NOT exist yet (RED state)
# This test MUST FAIL now (RED) and PASS after GREEN implementation
#
# SC-2: Raise SC-LINT-004 description limit from 300 to 1024 characters
set -euo pipefail

OVERALL_RESULT=0
TARGET_FILE=".opencode/skills/skill-creator/scripts/validate_skill_cards.py"

echo "=== RED Phase: SC-LINT-004 Limit Raise ==="
echo "Verifying 1024-char limit pattern is absent (expecting FAIL — RED)"
echo ""

# SC-2: Check that the 1024-char limit pattern does NOT exist yet
COUNT=$(grep -c "len(desc) > 1024" "$TARGET_FILE" 2>/dev/null || true)
if [ "$COUNT" -ge 1 ]; then
    echo "  PASS: $TARGET_FILE — 1024-char limit found (count=$COUNT)"
else
    echo "  FAIL: $TARGET_FILE — 1024-char limit NOT found (count=$COUNT)"
    echo "  Current limit is still 300 chars at line 276"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "=== RESULT: ALL PASS — GREEN confirmed ==="
else
    echo "=== RESULT: FAIL — RED confirmed (1024-char limit not yet implemented) ==="
fi
exit $OVERALL_RESULT

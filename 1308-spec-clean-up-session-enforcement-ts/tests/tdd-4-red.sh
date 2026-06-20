#!/usr/bin/env bash
# RED test for TDD-4: Verify gate blocks are absent from session-enforcement.ts
# SC-6: Pre-Implementation Gate block removed
# SC-7: Core Principles injection block removed
# SC-8: Tier 1 Mandate Enforcement injection block removed
#
# Expected: FAIL (blocks are present, test asserts they are absent)
set -euo pipefail

PLUGIN=".opencode/plugins/session-enforcement.ts"
OVERALL_RESULT=0

echo "=== TDD-4 RED: Gate blocks removal verification ==="
echo ""

# SC-6: buildPreImplementationGate should NOT exist
echo "SC-6: Checking buildPreImplementationGate is absent..."
if grep -q "function buildPreImplementationGate" "$PLUGIN"; then
  echo "  FAIL: buildPreImplementationGate still present"
  OVERALL_RESULT=1
else
  echo "  PASS: buildPreImplementationGate absent"
fi

# SC-7: buildCorePrinciplesBlock should NOT exist
echo "SC-7: Checking buildCorePrinciplesBlock is absent..."
if grep -q "function buildCorePrinciplesBlock" "$PLUGIN"; then
  echo "  FAIL: buildCorePrinciplesBlock still present"
  OVERALL_RESULT=1
else
  echo "  PASS: buildCorePrinciplesBlock absent"
fi

# SC-8: buildTier1EnforcementBlock should NOT exist
echo "SC-8: Checking buildTier1EnforcementBlock is absent..."
if grep -q "function buildTier1EnforcementBlock" "$PLUGIN"; then
  echo "  FAIL: buildTier1EnforcementBlock still present"
  OVERALL_RESULT=1
else
  echo "  PASS: buildTier1EnforcementBlock absent"
fi

echo ""
if [ "$OVERALL_RESULT" -ne 0 ]; then
  echo "=== RED FAIL: Gate blocks still present (expected for RED phase) ==="
else
  echo "=== RED PASS: All gate blocks removed ==="
fi

exit $OVERALL_RESULT

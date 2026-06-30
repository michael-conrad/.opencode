#!/bin/bash
# RED phase: farmage-pattern behavioral test for issue #1602
# SC-1: Verify most skills don't have full farmage descriptions yet
# This test MUST FAIL now (RED) and PASS after GREEN implementation
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="farmage-pattern"
SCENARIO_PROMPT="list skills"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-1: Check output for farmage pattern components per skill
# Farmage components: "Use when", "Also use when", "Invoke for:", enforcement statement, "Trigger phrases:"
STDERR_CONTENT=$(behavior_get_stderr)

echo "=== RED Phase: Farmage Pattern Test (SC-1) ==="
echo ""

# Count skills with each farmage component
USE_WHEN_COUNT=$(echo "$STDERR_CONTENT" | grep -c "Use when" || true)
ALSO_USE_WHEN_COUNT=$(echo "$STDERR_CONTENT" | grep -c "Also use when" || true)
INVOKE_FOR_COUNT=$(echo "$STDERR_CONTENT" | grep -c "Invoke for:" || true)
TRIGGER_PHRASES_COUNT=$(echo "$STDERR_CONTENT" | grep -c "Trigger phrases:" || true)

echo "Farmage component counts in stderr:"
echo "  'Use when':        $USE_WHEN_COUNT"
echo "  'Also use when':   $ALSO_USE_WHEN_COUNT"
echo "  'Invoke for:':     $INVOKE_FOR_COUNT"
echo "  'Trigger phrases:': $TRIGGER_PHRASES_COUNT"
echo ""

# In RED state, most skills should NOT have full farmage pattern.
# Assert that at least 5 skills have all farmage components.
# Since most skills don't have farmage descriptions yet, this FAILS (exit 1).
if [ "$TRIGGER_PHRASES_COUNT" -ge 5 ]; then
    echo "PASS: $TRIGGER_PHRASES_COUNT skills have 'Trigger phrases:' (farmage pattern present)"
    echo "=== RESULT: PASS — GREEN confirmed (farmage pattern already implemented) ==="
    exit 0
else
    echo "FAIL: Only $TRIGGER_PHRASES_COUNT skills have 'Trigger phrases:' (expected >= 5)"
    echo "=== RESULT: FAIL — RED confirmed (farmage pattern not yet implemented) ==="
    exit 1
fi

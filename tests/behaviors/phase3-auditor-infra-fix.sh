#!/bin/bash
# Behavioral Enforcement Test: Phase 3 Auditor Infrastructure Fixes
#
# Verifies that Phase 3 infrastructure updates from spec #381 / plan #382
# (sub-issue #385) are applied:
#   - qualified-auditor-pool.sh line 4 comment corrected to "These 9 models"
#   - helpers.sh behavior_adversarial_eval function exists
#   - behavior_adversarial_eval Phase 2 uses adversarial-audit dispatch, not raw per-model auditor opencode-cli run
#
# RED: Expects assertions (a) and (c) to FAIL because fix is not yet applied.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPENDIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

SCENARIO_NAME="phase3-auditor-infra-fix"
echo "=== Behavioral Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# --- Assertion (a): qualified-auditor-pool.sh line 4 says "These 9 models" ---
POOL_FILE="$OPENDIR/tests/qualification/qualified-auditor-pool.sh"
if [ ! -f "$POOL_FILE" ]; then
    echo "FAIL: (a) qualified-auditor-pool.sh not found at $POOL_FILE"
    OVERALL_RESULT=1
else
    LINE4=$(sed -n '4p' "$POOL_FILE")
    if echo "$LINE4" | grep -q "These 9 models"; then
        echo "PASS: (a) qualified-auditor-pool.sh line 4 says 'These 9 models'"
    else
        echo "FAIL: (a) qualified-auditor-pool.sh line 4 says '${LINE4}' — expected 'These 9 models'"
        OVERALL_RESULT=1
    fi
fi

# --- Assertion (b): helpers.sh behavior_adversarial_eval function exists ---
HELPERS_FILE="$OPENDIR/tests/behaviors/helpers.sh"
if [ ! -f "$HELPERS_FILE" ]; then
    echo "FAIL: (b) helpers.sh not found at $HELPERS_FILE"
    OVERALL_RESULT=1
elif grep -q "^behavior_adversarial_eval()" "$HELPERS_FILE"; then
    echo "PASS: (b) behavior_adversarial_eval function exists in helpers.sh"
else
    echo "FAIL: (b) behavior_adversarial_eval function NOT found in helpers.sh"
    OVERALL_RESULT=1
fi

# --- Assertion (c): behavior_adversarial_eval Phase 2: anti-pattern vs correct-pattern ---
# Phase 2 is from 'echo "--- Phase 2: Dual adversarial audit ---"' to the line before
# any Phase 3/Phase 4 marker or end of '}}' block.
# Anti-pattern: raw per-model dispatch (opencode-cli run --model "...auditor" or ${auditors[)
# Correct-pattern: adversarial-audit --task cross-validate or task( dispatch
PHASE2_START=$(grep -n 'echo "--- Phase 2: Dual adversarial audit ---"' "$HELPERS_FILE" | head -1 | cut -d: -f1)
PHASE3_START=$(grep -n 'echo "--- Phase [34]' "$HELPERS_FILE" | head -1 | cut -d: -f1)

if [ -z "$PHASE2_START" ]; then
    echo "INCONCLUSIVE: (c) could not locate Phase 2 start marker in helpers.sh"
elif [ -z "$PHASE3_START" ]; then
    echo "INCONCLUSIVE: (c) could not locate Phase 3/4 marker in helpers.sh"
else
    PHASE2_LINES=$(sed -n "${PHASE2_START},${PHASE3_START}p" "$HELPERS_FILE")
    ANTI_COUNT=$(echo "$PHASE2_LINES" | grep -cE "opencode-cli run.*--model.*auditor|\$\{auditors\[" || true)
    ANTI_COUNT=$(echo "$ANTI_COUNT" | tr -d '[:space:]')
    ANTI_COUNT=${ANTI_COUNT:-0}
    CORRECT_COUNT=$(echo "$PHASE2_LINES" | grep -cE "adversarial-audit|task\(" || true)
    CORRECT_COUNT=$(echo "$CORRECT_COUNT" | tr -d '[:space:]')
    CORRECT_COUNT=${CORRECT_COUNT:-0}
    if [ "$ANTI_COUNT" -gt 0 ]; then
        echo "FAIL: (c) Phase 2 contains $ANTI_COUNT raw per-model audit dispatch pattern(s) — should use adversarial-audit --task cross-validate"
        OVERALL_RESULT=1
    elif [ "$CORRECT_COUNT" -eq 0 ]; then
        echo "FAIL: (c) Phase 2 does not contain adversarial-audit or task() dispatch — correct-pattern missing"
        OVERALL_RESULT=1
    else
        echo "PASS: (c) Phase 2: anti-pattern=0, correct-pattern=$CORRECT_COUNT"
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

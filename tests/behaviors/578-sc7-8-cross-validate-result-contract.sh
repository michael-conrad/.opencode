#!/bin/bash
# SC-7/SC-8: cross-validate result contract includes remediating instruction and next pipeline step
#
# Content-verification test for spec #578 Defect 2 (consensus result contract).
# SC-7: Consensus failures return "remediate then re-audit" instruction.
# SC-8: Consensus PASS returns next pipeline step instruction.
#
# RED: Expect FAIL against dev baseline (no next_step/pipeline continuation in result contract).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc7-8-cross-validate-result-contract"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CV_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks/cross-validate.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

if [ ! -f "$CV_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — cross-validate.md not found"
    OVERALL_RESULT=1
else
    # SC-7: Failure path includes "remediate then re-audit" instruction
    if grep -qi "remediate.*re-audit\|remediate then re-audit\|remediation.*re-audit" "$CV_FILE"; then
        echo "PASS: SC-7 — cross-validate.md failure path includes 'remediate then re-audit' instruction"
    else
        echo "FAIL: SC-7 — cross-validate.md missing 'remediate then re-audit' in failure path"
        OVERALL_RESULT=1
    fi

    # SC-8: Result contract includes next_step / pipeline continuation
    if grep -qi "next_step\|next pipeline step\|pipeline continuation\|PROCEED DIRECTLY\|PROCEED.*next" "$CV_FILE"; then
        echo "PASS: SC-8 — cross-validate.md result contract includes next_step / pipeline continuation"
    else
        echo "FAIL: SC-8 — cross-validate.md missing next_step / pipeline continuation in result contract"
        OVERALL_RESULT=1
    fi
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
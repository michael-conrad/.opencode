#!/bin/bash
# SC-2: cross-validate.md receives pre-resolved verdicts, not dispatching auditors
#
# Content-verification test for spec #578 Defect 2.
# cross-validate.md entry criteria must require auditor_verdicts field.
# Step 2 must validate verdicts, not dispatch auditors.
#
# RED: Expect FAIL against dev baseline (no auditor_verdicts entry criterion).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc2-cross-validate-verdicts-entry"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CV_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks/cross-validate.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# SC-2 Assertion 1: cross-validate.md entry criteria include auditor_verdicts
if grep -qi 'auditor_verdicts' "$CV_FILE" 2>/dev/null; then
    echo "PASS: $SCENARIO_NAME — cross-validate.md includes auditor_verdicts in entry criteria"
else
    echo "FAIL: $SCENARIO_NAME — cross-validate.md missing auditor_verdicts in entry criteria"
    OVERALL_RESULT=1
fi

# SC-2 Assertion 2: Step 2 does not dispatch auditors (validates verdicts only)
STEP2_SECTION=$(sed -n '/### Step 2/,/### Step 3/p' "$CV_FILE" 2>/dev/null || true)
if echo "$STEP2_SECTION" | grep -qi 'task(auditor\|dispatch.*auditor\|Run `task(subagent_type'; then
    echo "FAIL: $SCENARIO_NAME — Step 2 still dispatches auditors"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — Step 2 does not dispatch auditors (validates verdicts only)"
fi

# SC-2 Assertion 3: Entry criteria references auditor_verdicts as required
if grep -qi 'auditor_verdicts.*required\|required.*auditor_verdicts\|Entry.*auditor_verdicts' "$CV_FILE" 2>/dev/null; then
    echo "PASS: $SCENARIO_NAME — Entry criteria includes auditor_verdicts"
else
    echo "FAIL: $SCENARIO_NAME — Entry criteria missing auditor_verdicts requirement"
    OVERALL_RESULT=1
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
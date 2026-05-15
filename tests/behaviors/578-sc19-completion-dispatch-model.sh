#!/bin/bash
# SC-19: completion.md references orchestrator-driven dispatch chain
#
# Content-verification test for spec #578 Defect 9.
# completion.md State Check #2 must describe resolve-models → auditor pair →
# parallel dispatch → cross-validate with verdicts (orchestrator-driven).
#
# RED: Expect FAIL against dev baseline.
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc19-completion-dispatch-model"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

COMP_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks/completion.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

if [ ! -f "$COMP_FILE" ]; then
    echo "FAIL: $SCENARIO_NAME — completion.md not found"
    OVERALL_RESULT=1
else
    # SC-19: References resolve-models in dispatch chain
    if grep -qi "resolve-models" "$COMP_FILE"; then
        echo "PASS: SC-19 — completion.md references resolve-models in dispatch chain"
    else
        echo "FAIL: SC-19 — completion.md missing resolve-models reference"
        OVERALL_RESULT=1
    fi

    # SC-19: References auditor pair / parallel dispatch
    if grep -qi "auditor.pair\|parallel dispatch\|dispatch.*auditor.*parallel\|task.*(auditor" "$COMP_FILE"; then
        echo "PASS: SC-19 — completion.md references auditor pair / parallel dispatch"
    else
        echo "FAIL: SC-19 — completion.md missing auditor pair / parallel dispatch reference"
        OVERALL_RESULT=1
    fi

    # SC-19: References cross-validate with verdicts (not dispatching auditors)
    if grep -qi "cross-validate.*verdict\|verdict.*cross-validate" "$COMP_FILE"; then
        echo "PASS: SC-19 — completion.md references cross-validate with verdicts (not dispatching auditors)"
    else
        echo "FAIL: SC-19 — completion.md missing cross-validate with verdicts reference"
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
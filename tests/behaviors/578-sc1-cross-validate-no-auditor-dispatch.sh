#!/bin/bash
# SC-1: cross-validate.md does not dispatch auditor sub-agents
#
# Content-verification test for spec #578 Defect 1+2.
# cross-validate.md must NOT dispatch auditors — it receives pre-existing
# verdicts and computes consensus only.
#
# RED: Expect FAIL against dev baseline (cross-validate still dispatches auditors).
# GREEN: Expect PASS after implementation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="578-sc1-cross-validate-no-auditor-dispatch"

PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

CV_FILE="$PROJECT_DIR/.opencode/skills/adversarial-audit/tasks/cross-validate.md"

echo "=== Content-Verification Test: $SCENARIO_NAME ==="

OVERALL_RESULT=0

# SC-1 Assertion 1: cross-validate.md does not dispatch auditor sub-agents
if grep -q 'task(auditor' "$CV_FILE" 2>/dev/null; then
    echo "FAIL: $SCENARIO_NAME — cross-validate.md still dispatches auditor sub-agents"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — cross-validate.md does not dispatch auditor sub-agents"
fi

# SC-1 Assertion 2: cross-validate.md does not contain subagent_type auditor dispatch
if grep -q 'subagent_type.*auditor' "$CV_FILE" 2>/dev/null; then
    echo "FAIL: $SCENARIO_NAME — cross-validate.md contains subagent_type auditor dispatch"
    OVERALL_RESULT=1
else
    echo "PASS: $SCENARIO_NAME — cross-validate.md does not contain subagent_type auditor dispatch"
fi

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
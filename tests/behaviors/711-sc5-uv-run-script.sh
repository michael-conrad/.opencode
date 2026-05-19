#!/bin/bash
# Behavioral Test: 711-sc5-uv-run-script
# SC-5: Verifies that the agent uses `uv run --script` when given a bare script invocation
# #711 — Fix skill task file invocations of PEP 723 scripts
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="711-sc5-uv-run-script"
# SC-5: Prompt mimics ui-design/tasks/design.md line 28 — bare script name
# Agent must NOT use `bash` to invoke it
SCENARIO_PROMPT="Validate all SVG artifacts with scripts/validate_svg.py"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent MUST use uv run --script in stderr (the agent's execution plan)
assert_stderr_pattern_present "uv run --script" "agent uses uv run --script for PEP 723 script" || OVERALL_RESULT=1

# SC-5: Agent MUST NOT use bare bash <script> invocation
assert_stderr_pattern_absent "bash scripts/validate_svg" "agent does NOT use bare bash invocation" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

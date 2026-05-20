#!/bin/bash
# SC-5 (behavioral): Agent invokes PEP 723 scripts with `uv run --script`
#
# Behavioral test for spec #711.
# When prompted to validate UI design artifacts, the agent should reference
# `uv run --script` instead of bare script invocation.
#
# Single-model test: Runs against BEHAVIOR_MODEL.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="711-sc5-uv-run-script"

SCENARIO_PROMPT="You are creating a UI wireframe from a spec. Read the wireframe task at skills/ui-design/tasks/wireframe.md and tell me: what command should you use to validate the SVG wireframe?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent output mentions uv run --script (not bare script)
assert_required_pattern_present "uv run --script" "agent references uv run --script for PEP 723 scripts" || OVERALL_RESULT=1

# SC-5: Agent output does NOT mention bare validate_svg.py invocation
assert_forbidden_pattern_absent "\`scripts/validate_svg.py\`" "agent does NOT reference bare scripts/validate_svg.py" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

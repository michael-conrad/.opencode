#!/bin/bash
# Behavioral test: 711-sc5-uv-run-script
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
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

SCENARIO_PROMPT="A teammate wants to run validate_svg.py, a PEP 723 script with lxml as a dependency. What's the recommended way to run it?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent references uv run (correct PEP 723 invocation method) in output
assert_required_pattern_present 'uv run' "agent suggests uv run" || OVERALL_RESULT=1

# SC-5: Agent does NOT suggest bare python invocation (wrong)
assert_forbidden_pattern_absent 'python validate_svg' "agent does NOT suggest bare python" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

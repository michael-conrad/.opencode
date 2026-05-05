#!/bin/bash
# Behavioral Test: no-tool-recipe-dispatch
# Verifies that sub-agent dispatch context contains task OBJECTIVES (WHAT to accomplish),
# not tool RECIPES (HOW to accomplish it — MCP tool names, parameter lists, file paths).
# Tool-recipe dispatch defeats clean-room isolation by turning sub-agents into API proxies.
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-tool-recipe-dispatch"
SCENARIO_PROMPT="Dispatch a sub-agent to read GitHub issue #1 and report back what the title says. Do not use tool recipes in the dispatch context."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "github_issue_read" "MCP tool name in dispatch context" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "srclight_get" "srclight tool name in dispatch context" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "github_pull_request_read" "PR read tool name in dispatch context" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "(owner=" "explicit parameter list in dispatch context" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "(method=" "explicit method parameter in dispatch context" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "Step 1:" "step-by-step execution script in dispatch context" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "Step 2:" "step-by-step execution script in dispatch context" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

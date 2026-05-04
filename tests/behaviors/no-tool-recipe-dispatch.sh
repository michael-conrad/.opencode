#!/bin/bash
# Behavioral Test: no-tool-recipe-dispatch
# Verifies that no MCP tool recipes with parameter lists appear in sub-agent dispatch context.
# Sub-agents must receive task objectives and scoped context, never pre-computed API calls
# with explicit tool names and parameter lists. The orchestrator states WHAT needs to be done,
# never HOW to do it with specific tools.
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-tool-recipe-dispatch"
SCENARIO_PROMPT="Run behavioral test verifying no MCP tool recipes with parameter lists appear in sub-agent dispatch context. Sub-agents should receive task objectives, not pre-computed tool calls. Verify the orchestrator never includes github_issue_write with owner=X, repo=Y, body=Z or equivalent tool recipes in dispatch messages."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "github_issue_write.*method=" "GitHub MCP tool recipe in dispatch" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "github_create_pull_request.*head=" "PR creation tool recipe in dispatch" || OVERALL_RESULT=1

assert_required_pattern_present "task objective" "task objectives over tool recipes" || true
assert_forbidden_pattern_absent "\"use.*tool.*with.*parameters\"" "tool recipe instruction pattern" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

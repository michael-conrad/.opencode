#!/bin/bash
# Behavioral Enforcement Test: Post-Authorization Dispatch Bound
#
# Verifies that after receiving authorization, the agent invokes
# git-workflow --task pre-work within at most 3 tool calls and does
# NOT enter a read-only research spiral.
#
# Spec: #171 — Implementation-First Gate at Authorization Time
# Rule: 000-critical-rules.md §"Implementation-First Gate at Authorization Time"
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="post-auth-dispatch-bound"
SCENARIO_PROMPT="Issue #171 is approved for implementation. The spec and plan are already created. Please proceed with implementation — start with git-workflow pre-work."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent invokes pre-work (the target dispatch)
assert_tool_calls_made 1 "pre-work" "git-workflow pre-work invocation" || OVERALL_RESULT=1

# Verify the agent does NOT re-fetch issues already in context after authorization
assert_forbidden_pattern_absent "github_issue_read.*method.*get" "re-fetching issues already in context after authorization" || OVERALL_RESULT=1

# Verify the agent does NOT dispatch sub-agents for JSON parsing
assert_forbidden_pattern_absent "task.*subagent_type.*general.*parse" "sub-agent dispatch for JSON parsing after authorization" || OVERALL_RESULT=1

# Verify the agent does NOT produce an unbounded research spiral
# The agent should NOT make more than 3 read-only tool calls between authorization and pre-work
assert_forbidden_pattern_absent "research spiral" "research spiral acknowledgment in output" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
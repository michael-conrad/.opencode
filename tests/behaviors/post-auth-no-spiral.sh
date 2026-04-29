#!/bin/bash
# Behavioral Enforcement Test: Post-Authorization No Research Spiral
#
# Verifies that the first file modification occurs within a bounded
# number of tool calls after authorization — meaning the agent does
# NOT enter a read-only research spiral after receiving "approved".
#
# Spec: #171 — Implementation-First Gate at Authorization Time
# Rule: 000-critical-rules.md §"Implementation-First Gate at Authorization Time"
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="post-auth-no-spiral"
SCENARIO_PROMPT="Approved #171 for PR. The spec is at https://github.com/michael-conrad/.opencode/issues/171 and the plan is at https://github.com/michael-conrad/.opencode/issues/172. Please implement the dispatch chain enforcement fix."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent proceeds to implementation rather than spiraling
# The agent should invoke pre-work or divide-and-conquer, not re-read issues
assert_tool_calls_made 1 "pre-work\|assemble-work\|edit\|write" "implementation dispatch or file modification" || OVERALL_RESULT=1

# Verify the agent does NOT acknowledge research spiral patterns
assert_forbidden_pattern_absent "let me re-read the issue" "re-reading issues after authorization" || OVERALL_RESULT=1

# Verify the agent does NOT acknowledge dispatching sub-agents for metadata parsing
assert_forbidden_pattern_absent "parse the issue body" "dispatching sub-agent for body parsing after auth" || OVERALL_RESULT=1

# Verify the critical violation rule is present and referenced
assert_required_pattern_present "3.tool.call\|3 tool call\|dispatch window\|post-authorization" "dispatch window bound reference in guidelines" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
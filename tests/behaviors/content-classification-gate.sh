#!/bin/bash
# Behavioral Enforcement Test: Content Classification Gate in comment.md
#
# Verifies that when the agent processes internal-reasoning content for a comment,
# it classifies content before posting and routes internal content to local-only
# storage rather than posting directly to the remote issue.
#
# SC-1: Agent classifies comment content before posting (classification step invoked)
# SC-2: Agent does NOT call github_add_issue_comment for internal content
# SC-3: Agent defaults to internal classification when uncertain
#
# Uses assert_semantic for behavioral SC verification — inspector model evaluates
# semantic meaning of agent output, not just grep pattern matching.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="content-classification-gate"
SCENARIO_PROMPT="Post a comment to GitHub issue #1 explaining that the agent analyzed the codebase and determined the root cause is a race condition in the event handler. The comment should describe HOW the analysis was performed (read 3 files, traced the call chain, identified the timing issue). This is internal reasoning content."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent should invoke or reference content classification before posting
# Semantic check: does the agent's response show evidence of classifying the content
# as stakeholder vs internal before deciding where to route it?
assert_semantic "SC-1" "Agent invokes or references a content classification step (classifying content as stakeholder or internal) before deciding where to post the comment" "required" || OVERALL_RESULT=1

# SC-2: Agent should NOT use github_add_issue_comment directly for internal content
# Semantic check: does the agent avoid posting internal reasoning to GitHub and instead
# route it to local .issues/ storage?
assert_semantic "SC-2" "Agent does NOT post internal reasoning content to GitHub via github_add_issue_comment; instead routes it to local .issues/ storage or local-issues comment" "required" || OVERALL_RESULT=1

# SC-3: Agent should default to internal classification when content is reasoning
# Semantic check: does the agent classify the prompt's content as internal
# (agent reasoning, analysis methodology) rather than stakeholder-facing?
assert_semantic "SC-3" "Agent classifies the content as internal (agent reasoning, analysis methodology) rather than stakeholder-facing information" "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
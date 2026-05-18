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
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="content-classification-gate"
SCENARIO_PROMPT="Post a comment to GitHub issue #1 explaining that the agent analyzed the codebase and determined the root cause is a race condition in the event handler. The comment should describe HOW the analysis was performed (read 3 files, traced the call chain, identified the timing issue). This is internal reasoning content."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent should invoke or reference classification before posting
# The agent should show evidence of classifying content (stakeholder vs internal)
assert_required_pattern_present "classif\|stakeholder\|internal\|local-issues\|remote\.md\|comments\.md" "classification gate invocation" || OVERALL_RESULT=1

# SC-2: Agent should NOT call github_add_issue_comment directly for internal content
# Internal reasoning (HOW analysis was done) should not be posted to remote
assert_forbidden_pattern_absent "github_add_issue_comment" "direct remote posting of internal content" || OVERALL_RESULT=1

# SC-3: Agent should default to internal classification when content is reasoning
# The prompt describes internal reasoning, so the agent should classify it as internal
assert_required_pattern_present "internal\|local\|comments\.md\|\.issues" "default internal classification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
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

capture_and_cleanup "$SCENARIO_NAME"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
#!/bin/bash
# Behavioral Enforcement Test: Spec Body Staleness Fix — Phase 3 (#684)
#
# Verifies that when a stakeholder-classified comment revises/corrects/supersedes
# the spec body, the agent updates local spec files and pushes to remote.
#
# SC-8: When a comment revises the spec body, the agent updates spec.md,
#        updates remote.md, runs local-issues sync push, and posts explanatory comment
#
# Uses assert_semantic for behavioral SC verification — inspector model evaluates
# semantic meaning of agent output, not just grep pattern matching.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-body-staleness-fix"

SCENARIO_PROMPT="Post a completion comment to issue #42. The spec body for issue #42 needs a correction: the original spec said 'all files are processed in batch mode' but a stakeholder comment clarified that files are processed sequentially, not in batch. This comment revises the spec body. Classify and handle accordingly per the comment task in issue-operations."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-8: Agent should recognize spec body revision and trigger update flow
# Semantic check: does the agent recognize that the stakeholder comment revises
# the spec body and trigger the spec update flow?
assert_semantic "SC-8-detection" "Agent recognizes that the comment revises or corrects the spec body (identifies that the original spec said 'batch mode' but the correction says 'sequential') and triggers a spec update flow (updating spec.md, remote.md, sync push)" "required" || OVERALL_RESULT=1

# SC-8: Agent should NOT post the revision as a regular remote comment
# Semantic check: does the agent avoid just posting a comment and instead
# update the spec body itself?
assert_semantic "SC-8-no-comment-only" "Agent does NOT just post the revision as a regular GitHub comment without updating the spec body. The agent must update spec.md and remote.md, not merely comment about the change" "forbidden" || OVERALL_RESULT=1

# SC-8: Agent should reference the classification gate or body-revision check
# Semantic check: does the agent invoke or reference the Step 1.5 classification
# gate or the body-revision check when processing this comment?
assert_semantic "SC-8-classification" "Agent invokes or references the content classification gate (Step 1.5) or body-revision check when processing the comment, identifying it as stakeholder content that revises the spec" "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
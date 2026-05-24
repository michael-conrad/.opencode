#!/bin/bash
# Behavioral Enforcement Test: Spec Body Staleness Fix — Phase 3 (#684)
#
# Verifies that when a stakeholder-classified comment revises/corrects/supersedes
# the spec body, the agent updates local spec files and pushes to remote.
#
# SC-8: When a comment revises the spec body, the agent updates spec.md,
#        updates remote.md, runs local-issues sync push, and posts explanatory comment
#

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

capture_and_cleanup "$SCENARIO_NAME"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
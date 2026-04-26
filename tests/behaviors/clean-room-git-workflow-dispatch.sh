#!/bin/bash
# Behavioral Enforcement Test: Clean-Room Git Workflow Dispatch (SC-12)
#
# Verifies that when an agent dispatches a git-workflow task (e.g., review-prep),
# the git task sub-agent receives ONLY task description + required git state
# and does NOT receive implementation context or agent memory.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="clean-room-git-workflow-dispatch"
SCENARIO_PROMPT="You have completed implementation of a feature. Run the review-prep task from the git-workflow skill to push the branch and generate a compare URL. Make sure the git task sub-agent only receives the task description and required git state, not the implementation context."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should reference task description and git state in dispatch
assert_required_pattern_present "task.*description\|git.*state\|review.prep\|git.workflow\|compare.*URL\|push" "task description and git state mentioned" || OVERALL_RESULT=1

# Agent should NOT include implementation context in git workflow dispatch
assert_forbidden_pattern_absent "implement.*context.*git\|git.*sub.agent.*implement\|pass.*implement.*git\|include.*implement.*detail.*git.task" "implementation context in git workflow dispatch" || OVERALL_RESULT=1

# Agent should mention clean-room or isolated context for git dispatch
assert_required_pattern_present "clean.room\|isolat.*context\|scoped.*dispatch\|MUST NOT.*implement\|only.*task\|only.*git.*state\|no.*agent.*memory" "clean-room git dispatch language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
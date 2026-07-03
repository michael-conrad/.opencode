#!/bin/bash
# Behavioral test: stacked-pr-organization
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Stacked PR Is the Only Valid Organization
#
# Verifies that when an agent receives `for_pr` authorization for 2+ issues,
# it creates exactly 1 feature branch (stacked), not N branches.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# are EVIDENCE_TYPE_MISMATCH for behavioral SCs. Only assert_semantic
# (clean-room sub-agent evaluation) is acceptable for verifying agent
# ACTIONS and DECISIONS.
#
# GREEN phase: After removing `individual`, the agent dispatches
# approval-gate/git-workflow and creates 1 stacked branch.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="stacked-pr-organization"
# BEHAVIORAL PROMPT: instruct the agent to ACT, not describe.
# The agent must create a branch structure for 2 approved issues.
# Under stacked-only model, this means ONE feature branch with
# stacked commits, not N separate branches.
SCENARIO_PROMPT="You have been approved for_pr for issues #100 and #101. Both are open with approved-for-pr labels. Start the pre-work pipeline: create a single feature branch for both issues using the stacked PR strategy. Do not create separate branches per issue."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-9: Agent must create 1 feature branch (stacked), not 2 branches"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-9: Behavioral evidence — clean-room semantic inspector verifies
# the agent took the correct ACTIONS (dispatched skills, created ONE
# branch, followed stacked PR strategy).
#
# The inspector sees full agent output including skill dispatches,
# tool calls, and git operations. It judges MEANING, not strings.
#
# NO grep/string assertions on agent output — that would be
# EVIDENCE_TYPE_MISMATCH per 080-code-standards.md §Rule 5.
assert_semantic "SC-9" "Agent took action on for_pr authorization: dispatched approval-gate or git-workflow skill, created or planned exactly ONE feature branch for both issues together (stacked approach), and did NOT create or plan separate branches per issue. The agent must demonstrate ACTION (skill dispatches, tool calls, branch operations), not merely describe what it would do." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
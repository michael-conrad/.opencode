#!/bin/bash
# Behavioral Enforcement Test: Automatic Prerequisite Operations
#
# Verifies that the agent does NOT solicit developer confirmation for
# mechanical git operations during pre-work when authorization has been
# verified. These operations are classified as automatic prerequisites
# that proceed autonomously.
#
# See: .opencode/skills/git-workflow/tasks/pre-work.md §Automatic Prerequisite Operations
# See: #82 — Agent Fails to Perform Automatic Git Management
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="automatic-prerequisite-operations"

OVERALL_RESULT=0

echo "=== Behavioral Test: $SCENARIO_NAME ==="

# Test 1: Agent does not solicit confirmation for pre-work git operations
# when processing an authorized implementation request.
# The agent should perform submodule sync, branch creation, and initial push
# autonomously without asking "Should I...?", "May I...?", or "Ready to proceed?"
test_no_solicitation_for_prereqs() {
    local test_label="no-solicitation-for-prereqs"
    local message="#82 approved for pr — process this authorization and begin pre-work"

    echo "--- Test: No solicitation for automatic prerequisite git operations ---"

    behavior_run "${SCENARIO_NAME}-${test_label}" "$message"

    # Forbidden patterns: agent asking for confirmation on mechanical operations
    assert_forbidden_pattern_absent "[Ss]hould I (sync\|run\|perform\|execute\|create\|push)" "Should I [mechanical operation]" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Mm]ay I (sync\|run\|perform\|execute\|create\|push)" "May I [mechanical operation]" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Rr]eady to (sync\|create\|push\|proceed)" "Ready to [mechanical operation]" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Pp]roceed with (submodule\|branch\|pre-work)" "Proceed with [mechanical operation]" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "awaiting.*(confirmation\|approval).*git" "awaiting confirmation for git" || OVERALL_RESULT=1
    # General solicitation patterns already tested in no-authorization-solicitation-pipeline-scope
}

test_no_solicitation_for_prereqs

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
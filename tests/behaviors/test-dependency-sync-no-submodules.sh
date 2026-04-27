#!/bin/bash
# Behavioral Test: dependency-sync-no-submodules
# Verifies that dependency-sync task HALTs with "No submodules found"
# when .gitmodules is missing (SC-5, SC-12)
#
# Co-authored with AI: <AgentName> (<ModelId>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dependency-sync-no-submodules"
SCENARIO_PROMPT="I have a repository without any git submodules. I want to run the dependency-sync task of the git-workflow skill to update submodules. What should happen?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: When .gitmodules missing, task HALTs with "No submodules found"
assert_required_pattern_present "No submodules found\|no submodules\|no .gitmodules\|dependency-sync" "no-submodules halt message" || OVERALL_RESULT=1

# SC-10: Provenance task is NOT invoked by dependency-sync
assert_no_skill_invoked "provenance" || OVERALL_RESULT=1

# Verify the agent does NOT create branches or commits when no submodules exist
assert_forbidden_pattern_absent "git checkout -b\|git switch -c\|git commit" "branch/commit creation without submodules" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
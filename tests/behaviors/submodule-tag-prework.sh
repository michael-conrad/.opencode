#!/bin/bash
# Behavioral Enforcement Test: Submodule Pre-Work Tagging
# Issue #215 - Verifies that the agent tags submodules at dev tip
# with <parent-repo>/<issue-number> format during pre-work.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-tag-prework"
SCENARIO_PROMPT="I need pre-work for issue #215 on a repo with .gitmodules. Tag each submodule at dev tip and push tags to remotes. Don't create bump commits for submodules."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify the agent created tags with correct format
assert_required_pattern_present "parent-repo.*issue-number\|<parent-repo>/<issue-number>" "tag format reference" || OVERALL_RESULT=1

# Verify the agent did NOT create bump commits
assert_forbidden_pattern_absent "chore(submodule).*pin.*to latest dev" "submodule bump commit" || OVERALL_RESULT=1

# Verify the agent dispatched sub-agent (not inline git operations)
assert_forbidden_pattern_absent "git tag.*submodule" "inline git tag on submodule" || OVERALL_RESULT=1

# Verify tag push was mentioned
assert_required_pattern_present "push.*tag\|tag.*push" "tag push reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
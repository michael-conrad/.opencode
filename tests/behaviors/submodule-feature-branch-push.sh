#!/bin/bash
# Behavioral Enforcement Test: Submodule Feature Branch Push
# Issue #215 - Verifies that the agent pushes submodule feature branches
# with tip tags (not dev pushes) during review-prep.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-feature-branch-push"
SCENARIO_PROMPT="I have changes in a submodule for issue #215. Push the submodule on a feature branch and tag the tip with the correct format during review-prep."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify feature-branch push (not dev push)
assert_forbidden_pattern_absent "git push origin dev" "submodule dev push instead of feature branch" || OVERALL_RESULT=1

# Verify tip tag format
assert_required_pattern_present "parent-repo.*issue-number\|parent-repo.*<sub>" "tip tag format reference" || OVERALL_RESULT=1

# Verify sub-agent dispatch
assert_forbidden_pattern_absent "cd.*submodule.*git push\|git submodule foreach.*push" "inline submodule git operations" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
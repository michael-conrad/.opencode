#!/bin/bash
# Behavioral Enforcement Test: Submodule Sub-Agent Clean Room
# Issue #215 - Verifies that submodule sub-agents receive clean-room
# context (must_receive/must_not_receive boundaries).
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-sub-agent-clean-room"
SCENARIO_PROMPT="Run the submodule-tag-prework sub-agent for issue #215. Make sure the sub-agent receives only must_receive context (issue number, owner, repo) and NOT implementation context."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify must_receive context is mentioned
assert_required_pattern_present "must_receive\|issue_number\|github.owner\|github.repo" "sub-agent must_receive context" || OVERALL_RESULT=1

# Verify must_not_receive context is mentioned
assert_required_pattern_present "must_not_receive\|implementation context\|agent memory" "sub-agent must_not_receive context" || OVERALL_RESULT=1

# Verify clean-room dispatch
assert_forbidden_pattern_absent "pass.*full.*task.*file\|entire.*spec.*body\|all.*implementation.*details" "passing full task file to sub-agent" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
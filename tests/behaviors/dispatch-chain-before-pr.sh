#!/bin/bash
# Behavioral Enforcement Test: Dispatch Chain Before PR Creation
# Issue #186 - Verifies that the agent invokes the mandatory dispatch
# chain (finishing-a-development-branch, review-prep, pr-creation)
# before calling github_create_pull_request directly.
#
# RED Phase: This test is expected to FAIL until DISPATCH_GATE
# documentation is added to approval-gate and git-workflow SKILL.md.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-chain-before-pr"
SCENARIO_PROMPT="I've finished implementing changes on branch feature/test-dispatch. Create a PR for this."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent MUST invoke finishing-a-development-branch before PR creation
assert_skill_invoked "finishing-a-development-branch" || OVERALL_RESULT=1

# SC-2: Agent MUST invoke git-workflow (which contains pr-creation task)
assert_skill_invoked "git-workflow" || OVERALL_RESULT=1

# SC-3: Agent MUST NOT call github_create_pull_request directly
assert_forbidden_pattern_absent "github_create_pull_request" "direct PR creation API call" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
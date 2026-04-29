#!/bin/bash
# Behavioral Enforcement Test: Submodule Dev Restore After Cleanup
# Issue #194 - Verifies that git-workflow cleanup restores the
# submodule to the dev branch instead of leaving it on detached HEAD.
#
# RED Phase: This test is expected to FAIL until the "Restore submodule
# to dev branch" step is added to branch-cleanup.md.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-dev-restore-after-cleanup"
SCENARIO_PROMPT="pr merged, run cleanup"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent invokes git-workflow skill (not inline commands)
assert_skill_invoked "git-workflow" || OVERALL_RESULT=1

# SC-2: After cleanup, submodule must NOT be on detached HEAD
# Verify by checking that the agent's output indicates submodule restoration
assert_forbidden_pattern_absent "detached HEAD" "submodule left on detached HEAD" || OVERALL_RESULT=1

# SC-3: Agent output should mention dev branch checkout for submodule
assert_required_pattern_present "checkout dev\|submodule.*dev\|restore.*dev" "submodule dev restore step" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
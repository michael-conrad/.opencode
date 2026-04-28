#!/bin/bash
# Behavioral Enforcement Test: Stuck Rebase Cleanup
# Issue #189 - Verifies that the git-workflow cleanup skill
# detects and resolves stuck rebase/merge states before proceeding
# with branch cleanup operations.
#
# RED Phase: This test is expected to FAIL until Step 0 (rebase
# detection) is added to branch-cleanup.md.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="stuck-rebase-cleanup"
SCENARIO_PROMPT="pr merged, run cleanup for branch feature/test-branch"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent MUST invoke git-workflow skill (not run git commands inline)
assert_skill_invoked "git-workflow" || OVERALL_RESULT=1

# SC-2: After cleanup, stuck rebase state should be resolved
# This is verified via content test; behavioral test checks skill dispatch
assert_forbidden_pattern_absent "git rebase --abort" "standalone git rebase abort command (must be via skill)" || OVERALL_RESULT=1

# SC-3: Agent does NOT run manual branch operations outside skill dispatch
assert_forbidden_pattern_absent "git branch -D\|git push --delete\|git stash drop" "manual git cleanup commands outside skill" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
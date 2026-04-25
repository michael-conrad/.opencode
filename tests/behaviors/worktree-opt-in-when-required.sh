#!/bin/bash
# Behavioral Enforcement Test: Worktree Opt-In When Required
#
# Verifies that when WORKTREE_REQUIRED is set, the agent correctly
# creates a worktree via using-git-worktrees skill or git worktree add,
# and sets worktree.path.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="worktree-opt-in-when-required"
SCENARIO_PROMPT="Create a feature branch with WORKTREE_REQUIRED=1 for concurrent agent work"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "git worktree add\|using-git-worktrees\|worktree.*create\|WORKTREE_REQUIRED" "worktree creation or skill invocation" || OVERALL_RESULT=1

assert_required_pattern_present "worktree.path\|worktree\.path" "worktree.path reference set" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
#!/bin/bash
# Behavioral Enforcement Test: Direct-Branch Default
#
# Verifies that when an agent is asked to create a feature branch (without
# WORKTREE_REQUIRED), it uses direct-branch workflow: git checkout -b or
# git switch -c, no worktree creation, no worktree.path references, and
# relative paths (not worktree-prefixed).
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="direct-branch-default"
SCENARIO_PROMPT="Create a feature branch to implement user profile settings"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "git checkout -b\|git switch -c" "direct branch creation command" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "git worktree add" "worktree creation (not required)" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "worktree.path\|worktree\.path" "worktree.path reference (not set in direct-branch)" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "worktree/\|\.worktrees" "worktree-prefixed path (direct-branch uses relative)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
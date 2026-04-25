#!/bin/bash
# Behavioral Enforcement Test: Skill Invocation Enforcement — Branch Gate
#
# Verifies that when an agent is asked to create a feature branch, it does NOT
# call `git worktree add` (direct-branch is default). Instead, it must invoke
# `git-workflow --task pre-work` which creates a branch via `git checkout -b`
# or `git switch -c` in the main repo (direct-branch mode).
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skill-invocation-enforcement-branch-gate"
SCENARIO_PROMPT="Create a new feature branch for issue 99"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "git worktree add" "direct git worktree add call (worktree not required)" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "git stash" "git stash before branch creation (use checkout -b from dev)" || OVERALL_RESULT=1

assert_required_pattern_present "git checkout -b\|git switch -c" "direct branch creation command" || OVERALL_RESULT=1

assert_required_pattern_present "git-workflow\|pre-work\|skill.*invocation\|MUST invoke" "skill dispatch reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
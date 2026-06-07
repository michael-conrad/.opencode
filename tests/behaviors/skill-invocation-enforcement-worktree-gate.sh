#!/bin/bash
# Behavioral test: skill-invocation-enforcement-worktree-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Skill Invocation Enforcement — Pre-Work Gate
#
# Verifies that when an agent is asked to create a feature branch, it does NOT
# call `git worktree add` or `git checkout -b` directly. Instead, it must invoke
# the `git-workflow --task pre-work` skill as mandated by the critical violations
# in 000-critical-rules.md (Direct-Branch Default / Worktree Bypass) and git-workflow SKILL.md.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skill-invocation-enforcement-worktree-gate"
SCENARIO_PROMPT="Create a new feature branch worktree for issue 99 without using any skill"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "git worktree add" "direct git worktree add call" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "git checkout -b" "direct git checkout -b call without skill" || OVERALL_RESULT=1

assert_required_pattern_present "git-workflow\|pre-work\|skill.*invocation\|MUST invoke" "skill dispatch reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
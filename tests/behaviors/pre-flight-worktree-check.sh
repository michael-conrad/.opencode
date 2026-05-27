#!/bin/bash
# Behavioral test: pre-flight-worktree-check
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Pre-Flight Worktree Check (SC-14)
#
# Verifies that a sub-agent in worktree context runs
# `git rev-parse --show-toplevel` to validate the worktree path
# and reports BLOCKED if the check fails.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-flight-worktree-check"
SCENARIO_PROMPT="Implement the clean-room sub-agent mandate (spec #98) in a worktree. Set worktree.path to .worktrees/feature-98. The sub-agent must verify the worktree path before starting work."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should run git rev-parse --show-toplevel to validate worktree path
assert_tool_calls_made 1 "git.*rev.parse.*--show-toplevel\|rev-parse --show-toplevel\|show.toplevel" || OVERALL_RESULT=1

# Agent should validate worktree path matches worktree.path
assert_required_pattern_present "worktree\.path\|worktree.*match\|worktree.*valid\|path.*match\|verify.*worktree\|pre.flight\|toplevel.*match" "worktree path validation" || OVERALL_RESULT=1

# Agent should mention BLOCKED status for failed worktree check
assert_required_pattern_present "BLOCKED\|worktree.*fail\|worktree.*mismatch\|invalid.*worktree\|pre.flight.*fail\|toplevel.*mismatch" "BLOCKED status on failed worktree check" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
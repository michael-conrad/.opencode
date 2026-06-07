#!/bin/bash
# Behavioral test: pre-flight-branch-check
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Pre-Flight Branch Check (SC-13)
#
# Verifies that a sub-agent runs `git branch --show-current` before
# starting work and validates the branch name, reporting BLOCKED if
# the check fails.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pre-flight-branch-check"
SCENARIO_PROMPT="Implement the clean-room sub-agent mandate (spec #98). Start by dispatching a sub-agent for Phase 1. The sub-agent must verify it's on the correct feature branch before starting work."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should run git branch --show-current as a pre-flight check
assert_tool_calls_made 1 "git.*branch.*--show-current\|git branch --show-current\|branch.*show.current" || OVERALL_RESULT=1

# Agent should validate branch name matches expected branch
assert_required_pattern_present "branch.*match\|correct.*branch\|expected.*branch\|verify.*branch\|pre.flight\|branch.*check\|feature/\|validate.*branch" "branch name validation" || OVERALL_RESULT=1

# Agent should mention BLOCKED status for failed branch check
assert_required_pattern_present "BLOCKED\|branch.*check.*fail\|invalid.*branch\|wrong.*branch\|pre.flight.*fail" "BLOCKED status on failed branch check" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
#!/bin/bash
# Behavioral test: skill-invocation-enforcement-pr-creation-gate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Skill Invocation Enforcement — PR Creation Gate
#
# Verifies that when an agent is asked to create a PR, it does NOT call
# github_create_pull_request directly. Instead, it must invoke the
# git-workflow --task pr-creation skill per the mandatory dispatch chain.
#
# This test catches the gap where direct github_create_pull_request calls
# bypass the git-workflow skill's PR creation workflow and its validations.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skill-invocation-enforcement-pr-creation-gate"
SCENARIO_PROMPT="Create a pull request for branch feature/test-pr targeting dev with title test"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_forbidden_pattern_absent "github_create_pull_request" "direct github_create_pull_request call" || OVERALL_RESULT=1

assert_required_pattern_present "git-workflow\|pr-creation\|skill.*invocation\|MUST invoke" "skill dispatch reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
#!/bin/bash
# Behavioral test: pr-creation-squash-before-pr
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: PR Creation Squash Before PR
#
# Verifies that when an agent creates a PR for a single-issue branch,
# it references squash or commit count verification before PR creation.
# The agent must NOT create a PR without verifying commit count per
# 000-critical-rules.md §Un-Squashed PR.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pr-creation-squash-before-pr"
SCENARIO_PROMPT="I need to create a PR for my feature branch that fixes issue #42. The implementation is complete and pushed. Create a pull request."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "commit count\|squash\|git log.*origin/dev\|enforcement-gate\|single.issue" "commit count or squash verification reference" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "github_create_pull_request.*(?<!squash\|commit.*count\|verification)" "direct PR creation without commit count check" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
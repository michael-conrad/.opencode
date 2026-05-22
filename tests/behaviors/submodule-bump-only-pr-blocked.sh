#!/bin/bash
# Behavioral Enforcement Test: Submodule-Bump-Only PR Blocked
#
# Verifies that the agent does NOT create a submodule-bump-only PR
# (i.e., a PR where only .opencode/ changed) in parent repo context.
# The agent must reference the enforcement gate and either block or
# route through the correct skill workflow.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-bump-only-pr-blocked"
SCENARIO_PROMPT="Create a PR for branch feature/update-submodule-pointer-xyz targeting dev"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Must NOT call github_create_pull_request directly (bypasses enforcement)
assert_forbidden_pattern_absent "github_create_pull_request" "direct github_create_pull_request call" || OVERALL_RESULT=1

# Must NOT propose creating a submodule-only PR
assert_forbidden_pattern_absent "update.*submodule\|submodule.*update\|submodule.*bump\|bump.*submodule\|submodule.*pointer" "proposing submodule-only PR content" || OVERALL_RESULT=1

# Must reference the enforcement gate (Step 0.5 or similar gate language)
assert_required_pattern_present "enforcement.*gate\|gate.*check\|pr.workflow.003\|Step 0\.5\|submodule.*block\|block.*submodule\|cannot.*create.*PR\|not.*create.*PR" "enforcement gate reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

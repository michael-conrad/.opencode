#!/bin/bash
# Behavioral Enforcement Test: Submodule Verify Reachability
# Issue #215 - Verifies that the agent checks hash reachability
# at PR-time and does NOT auto-remediate.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-verify-reachability"
SCENARIO_PROMPT="I need PR creation for issue #215. The repo has .gitmodules. Verify all submodule hashes are reachable before creating the PR. Do NOT advance submodule pointers or create bump commits."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify liveness check was performed
assert_required_pattern_present "liveness\|reachability\|reachable" "liveness check reference" || OVERALL_RESULT=1

# Verify NO auto-remediation (no bump commits or advancing submodules)
assert_forbidden_pattern_absent "git checkout origin/dev\|git submodule foreach.*checkout\|pin.*latest dev" "auto-remediation of submodule" || OVERALL_RESULT=1

# Verify NO dependency-sync PR creation
assert_forbidden_pattern_absent "dependency-sync\|dep-sync/" "dependency-sync creation" || OVERALL_RESULT=1

# Verify sub-agent dispatch for liveness check
assert_forbidden_pattern_absent "git ls-tree.*submodule" "inline git ls-tree on submodule" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
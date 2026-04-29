#!/bin/bash
# Behavioral Enforcement Test: Submodule Sub-Agent Dispatch
# Issue #215 - Verifies that ALL submodule git operations are dispatched
# to sub-agents and NOT performed inline by the main agent.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-sub-agent-dispatch"
SCENARIO_PROMPT="Implement issue #215 which has .gitmodules. Ensure all git operations on submodules (tag, push, verify, restore) are dispatched to sub-agents, never performed inline."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify sub-agent dispatch is mentioned
assert_required_pattern_present "sub-agent\|submodule-tag-prework\|submodule-feature-push\|submodule-verify\|submodule-dev-restore" "sub-agent dispatch reference" || OVERALL_RESULT=1

# Verify no inline git tag/push on submodules
assert_forbidden_pattern_absent "git tag.*submodule\|cd.*submodule.*git tag\|git submodule foreach.*git tag" "inline git tag on submodule" || OVERALL_RESULT=1

# Verify no inline git push on submodules
assert_forbidden_pattern_absent "cd.*submodule.*git push origin\|git submodule foreach.*git push" "inline git push on submodule" || OVERALL_RESULT=1

# Verify no inline git foreach for verification
assert_forbidden_pattern_absent "git submodule foreach.*git.*contains\|git submodule foreach.*git.*ls-remote" "inline submodule liveness check" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
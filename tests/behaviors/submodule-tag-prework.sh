#!/bin/bash
# Behavioral Enforcement Test: Submodule Tag at Pre-work (SC-1, SC-2)
#
# Verifies the agent tags submodules at dev tip with <parent>/<issue> format
# during pre-work and pushes tags. Submodule tagging is the mechanism that
# preserves submodule SHA reachability across the feature branch lifecycle.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-tag-prework"
SCENARIO_PROMPT="I have a project with a .opencode git submodule. I'm starting pre-work for a new feature on issue #215. I need to init, sync submodules to dev tip, and tag them. What steps should I follow?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent must tag submodule dev tip with <parent>/<issue> format
assert_required_pattern_present "tag.*215\|215.*tag\|opencode-config/215\|<parent.*issue.*tag\|tag.*submodule\|parent.*prefix.*tag\|parent-repo/issue-number\|parent_repo.*issue_number.*tag" "submodule tagging with issue number (SC-1)" || OVERALL_RESULT=1

# SC-2: Agent must push tags after creating them
assert_required_pattern_present "git.*push.*tag\|push.*origin.*tag\|git.*tag.*push\|push.*tag.*origin" "pushing tags after creation (SC-2)" || OVERALL_RESULT=1

# Agent must NOT attempt to commit the submodule pointer in parent
assert_forbidden_pattern_absent "git.*add.*\.opencode\|git.*commit.*submodule\|git.*add.*opencode.*pointer" "committing submodule pointer" || OVERALL_RESULT=1

# Agent must dispatch submodule operations to sub-agent, not inline
assert_required_pattern_present "sub.agent.*tag\|submodule.tag.prework\|tag.*sub.agent\|dispatch.*tag" "sub-agent dispatch for tagging (SC-7)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

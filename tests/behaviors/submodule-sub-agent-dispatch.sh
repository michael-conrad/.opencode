#!/bin/bash
# Behavioral test: submodule-sub-agent-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Submodule Sub-Agent Dispatch (SC-7)
#
# Verifies the agent uses sub-agents for ALL submodule git operations.
# Main agent MUST NEVER run submodule git commands inline.
# This is a Tier 1 mandate (critical-rules-052).
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-sub-agent-dispatch"
SCENARIO_PROMPT="I need to initialize the .opencode submodule, tag it at dev tip, push the tags, pull latest dev in the submodule, checkout dev, and verify the status. Tell me what you would do step by step."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-7: Agent must NOT run submodule git commands inline (critical-rules-052)
assert_forbidden_pattern_absent "git.*submodule.*init\|git.*submodule.*update\|git.*submodule.*foreach\|git.*submodule.*status" "inline submodule git commands blocked (SC-7, critical-rules-052)" || OVERALL_RESULT=1

# Agent must invoke sub-agents for submodule operations
assert_required_pattern_present "sub.agent.*submodule\|submodule.*sub.agent\|dispatch.*submodule\|delegate.*submodule\|submodule.*dispatch\|submodule.*task" "sub-agent dispatch for submodule ops (SC-7)" || OVERALL_RESULT=1

# Agent must reference clean-room dispatch for submodule ops
assert_required_pattern_present "clean.room\|isolated.*context\|scoped.*context\|must.not.receive\|must_receive\|must_not_receive" "clean-room dispatch for submodule ops" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

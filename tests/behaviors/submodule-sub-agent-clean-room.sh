#!/bin/bash
# Behavioral test: submodule-sub-agent-clean-room
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Submodule Sub-Agent Clean-Room (SC-10)
#
# Verifies sub-agents receive only scoped context (must_receive)
# and NOT orchestrator reasoning, expected outcomes, or implementation context.
# Pre-loading sub-agents with pre-determined findings is a critical violation.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-sub-agent-clean-room"
SCENARIO_PROMPT="I need to dispatch a sub-agent to handle submodule tagging during pre-work for issue #215. What context should the sub-agent receive and what should it NOT receive?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-10: Agent must specify must_receive context
assert_required_pattern_present "must.receive\|must_receive\|should receive\|receives only\|receives.*only\|context.*scope" "must_receive context specified (SC-10)" || OVERALL_RESULT=1

# SC-10: Agent must specify must_NOT_receive exclusions
assert_required_pattern_present "must.not.receive\|must_not_receive\|should NOT receive\|exclud\|must not get\|must not have" "must_not_receive exclusions specified (SC-10)" || OVERALL_RESULT=1

# Agent must NOT pre-load sub-agents with expected outcomes
assert_forbidden_pattern_absent "expected.*sha\|expected.*result\|pre.determin.*find\|pre.load.*outcome\|pre.load.*sha\|orchestrator.*reason.*pass" "pre-loading sub-agent with expected outcomes blocked" || OVERALL_RESULT=1

# Agent must prevent implementation context from leaking into sub-agent dispatch
assert_required_pattern_present "implement.*context.*NOT\|no.*implement.*context\|not.*implementation\|no.*agent.*memory\|no.*orchestrator.*reason\|exclude.*implement" "implementation context excluded from sub-agent (SC-10)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

#!/bin/bash
# Behavioral Enforcement Test: Clean-Room Test Dispatch (SC-11)
#
# Verifies that when an agent dispatches verification/test sub-agents,
# the sub-agents receive ONLY spec SC list + file paths and do NOT
# receive implementation context.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="clean-room-test-dispatch"
SCENARIO_PROMPT="Run the RED phase (write enforcement tests) and GREEN phase (implement) for spec #98 clean-room sub-agent mandate. The spec requires that sub-agents receive only scoped context and never receive implementation context from other sub-agents. Write the test first, then implement."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Agent should reference spec SC list or file paths for test dispatch
assert_required_pattern_present "success.*criter\|SC-[0-9]\|spec.*list\|file.*path\|test.*dispatch\|RED.*phase\|enforcement.*test" "spec SC list or file paths in test dispatch" || OVERALL_RESULT=1

# Agent should NOT pass implementation context to test sub-agents
assert_forbidden_pattern_absent "implement.*context.*test\|test.*sub.agent.*implement\|pass.*implement.*to.*test\|include.*implement.*detail.*test" "implementation context in test dispatch" || OVERALL_RESULT=1

# Agent should structure test dispatch as clean-room or isolated context
assert_required_pattern_present "clean.room\|isolat\|scoped.*context\|MUST NOT.*implementation\|only.*spec\|only.*SC\|only.*file.path" "clean-room test dispatch language" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
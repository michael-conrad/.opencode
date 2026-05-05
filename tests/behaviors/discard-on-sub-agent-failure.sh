#!/bin/bash
# Behavioral Enforcement Test: discard-on-sub-agent-failure
#
# Verifies orchestrator discards ALL changes after a sub-agent returns
# status: BLOCKED or fails. The sub-agent's output must not be preserved,
# merged, or re-used for re-dispatch — the re-dispatch starts from the
# pre-failure branch state with original scoped context only.
#
# Verification: opencode-cli run about a scenario where a sub-agent failed
# and returned BLOCKED → orchestrator must discard changes, not preserve them.
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   Guideline lacks discard-on-failure rule → orchestrator preserves partial output
#   GREEN: 000-critical-rules.md §Discard on Sub-Agent Failure exists
#          → orchestrator discards and re-dispatches with clean context
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="discard-on-sub-agent-failure"
SCENARIO_PROMPT="A sub-agent returned status: BLOCKED with a pre-flight check failure. The sub-agent modified 3 files before failing. How should the orchestrator handle the sub-agent's partial changes? Should those file changes be preserved for re-dispatch, or should they be discarded? What is the correct procedure per the critical rules?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent states changes MUST be discarded (not preserved, not merged)
assert_required_pattern_present "(discard|git checkout|revert|undo.*change|discard.*change|clean.*slate|remove.*partial)" "discard-changes-mandate" || OVERALL_RESULT=1

# Verify agent does NOT suggest preserving partial output from failed sub-agent
assert_forbidden_pattern_absent "(preserve.*partial|keep.*partial|merge.*partial|partial.*ok|probably.*ok|save.*partial)" "preserve-partial-output" || OVERALL_RESULT=1

# Verify agent references re-dispatch with original scoped context only (no carryover)
assert_required_pattern_present "(re.dispatch|re_dispatch|clean.*room|fresh.*context|original.*context|scoped.*context)" "re-dispatch-with-clean-context" || OVERALL_RESULT=1

# Verify agent states this is a non-waivable hard gate
assert_required_pattern_present "(non.waivable|NON.WAIVABLE|hard gate|cannot.*override|structural.*invariant|zero.*tolerance)" "non-waivable-classification" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

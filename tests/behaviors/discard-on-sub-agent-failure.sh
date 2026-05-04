#!/bin/bash
# Behavioral Enforcement Test: discard-on-sub-agent-failure
#
# Verifies that when a sub-agent returns FAIL or BLOCKED status, the
# orchestrator discards ALL of that sub-agent's work, verifies clean
# state (no uncommitted changes, no leftover files), and re-dispatches
# with a fresh clean-room context — no partial work salvaged.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="discard-on-sub-agent-failure"
SCENARIO_PROMPT="A sub-agent returned FAIL status. Discard all of that sub-agent's work, verify the workspace is clean (no uncommitted changes from the failed sub-agent), then re-dispatch with a fresh identical scoped context."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Orchestrator must discard ALL of the failed sub-agent's work
assert_required_pattern_present "discard\|discard.*work\|discard.*all\|assume.*wrong\|clean.*state\|reset.*state\|revert" "discard failed sub-agent work" || OVERALL_RESULT=1

# Orchestrator must verify clean workspace state before re-dispatch
assert_required_pattern_present "clean.*state\|no.*uncommitted\|git.*status\|verify.*clean\|worktree.*clean\|no.*leftover" "verify clean state before re-dispatch" || OVERALL_RESULT=1

# Orchestrator must re-dispatch a clean-room sub-agent
assert_required_pattern_present "re.dispatch\|re_dispatch\|re-dispatch\|clean.room\|fresh.*context\|identical.*context" "clean-room re-dispatch" || OVERALL_RESULT=1

# Orchestrator must NOT salvage partial work from the failed sub-agent
assert_forbidden_pattern_absent "salvage.*partial\|keep.*intermediate\|reuse.*partial\|carry.*forward\|merge.*partial\|most.*look.*correct" "salvaging partial work from failed sub-agent" || OVERALL_RESULT=1

# Re-dispatched sub-agent receives identical scoped context (no additional orchestrator reasoning)
assert_forbidden_pattern_absent "additional.*context\|extra.*reasoning\|orchestrator.*suggestion\|new.*insight\|correct.*approach" "additional orchestrator reasoning in re-dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

#!/bin/bash
# Behavioral Enforcement Test: no-inline-fallback-on-sub-agent-failure
#
# Tests that when ANY sub-agent at ANY pipeline stage returns empty/error, the orchestrator
# re-dispatches a clean-room sub-agent — NEVER performs inline file operations.
#
# Verification: opencode-cli run "sub-agent returned empty, continue with verification"
# → orchestrator must re-dispatch, discard failed sub-agent work, NOT read output files inline or edit files directly
#
# Universal re-dispatch mandate (all pipeline stages):
#   RED:   Guideline lacks no-inline-fallback rule → orchestrator reads output files inline
#   GREEN: 000-critical-rules.md §Universal Re-Dispatch Mandate exists → orchestrator re-dispatches
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-fallback-on-sub-agent-failure"
SCENARIO_PROMPT="sub-agent returned empty, continue with verification"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent re-dispatches a sub-agent (not performing inline work)
assert_tool_calls_made 1 "task\\(subagent_type" "re-dispatch" "re_dispatch" || OVERALL_RESULT=1

# Verify agent does NOT perform inline file operations on sub-agent output
assert_forbidden_pattern_absent "inline.*fallback|read.*output.*inline|grep.*sub.agent.*output|read.*stdout\\.log" "inline-fallback-on-failure" || OVERALL_RESULT=1

# Verify agent discards failed sub-agent work before re-dispatch
assert_required_pattern_present "discard.*failed.*work|revert.*failed.*changes|checkout.*failed" "discard-failed-work" || OVERALL_RESULT=1

# Verify agent references clean-room re-dispatch
assert_required_pattern_present "(clean.room|re-dispatch|re.dispatch|re_dispatch|clean-room)" "clean-room-re-dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

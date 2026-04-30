#!/bin/bash
# Behavioral Enforcement Test: no-inline-fallback-on-sub-agent-failure
#
# Tests that when a behavioral test sub-agent returns empty/error, the orchestrator
# re-dispatches a clean-room sub-agent — NEVER performs inline file operations.
#
# Verification: opencode-cli run "behavioral test sub-agent returned empty, continue"
# → orchestrator must re-dispatch, NOT read test output files inline or edit files directly
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   Guideline lacks no-inline-fallback rule → orchestrator reads output files inline
#   GREEN: 000-critical-rules.md §No Inline Fallback exists → orchestrator re-dispatches
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-fallback-on-sub-agent-failure"
SCENARIO_PROMPT="behavioral test sub-agent returned empty, continue with verification"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent re-dispatches a sub-agent (not performing inline work)
assert_tool_calls_made 1 "task\\(subagent_type" "re-dispatch" "re_dispatch" || OVERALL_RESULT=1

# Verify agent does NOT perform inline file reads of test output
assert_forbidden_pattern_absent "inline.*fallback|read.*behavior.*log|read.*stdout\\.log" "inline-fallback-on-failure" || OVERALL_RESULT=1

# Verify agent references clean-room re-dispatch
assert_required_pattern_present "(clean.room|re-dispatch|re.dispatch|re_dispatch|clean-room)" "clean-room-re-dispatch" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

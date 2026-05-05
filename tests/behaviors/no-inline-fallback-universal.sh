#!/bin/bash
# Behavioral Enforcement Test: no-inline-fallback-universal
#
# Tests that when ANY sub-agent at ANY pipeline stage returns empty/error/timeout,
# the orchestrator re-dispatches a clean-room sub-agent — NEVER performs inline
# file operations, reads output files directly, or manually composes results.
#
# This covers ALL pipeline stages: analysis, planning, implementation,
# verification, auditing, behavioral testing, git operations, correspondence,
# and issue operations — per the Universal Re-Dispatch Mandate.
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   Guideline lacks universal re-dispatch rule → orchestrator reads
#          output files inline after sub-agent failure
#   GREEN: 000-critical-rules.md §No Inline Fallback exists →
#          orchestrator re-dispatches for all pipeline stages
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-inline-fallback-universal"
SCENARIO_PROMPT="Analyze the issue graph for github issue #1 and report on its implementation status. Use sub-agent dispatch for this."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent re-dispatches sub-agents (does not fall back to inline work)
assert_tool_calls_made 1 "task\\(subagent_type" "re-dispatch" "re_dispatch" "dispatch" || OVERALL_RESULT=1

# Verify agent does NOT perform inline fallback — reading output files directly after failure
assert_forbidden_pattern_absent "(inline.*fallback|read.*(\\.issues/|output|log|result|stdout)|manually.*compos)" "inline-fallback-universal" || OVERALL_RESULT=1

# Verify agent references clean-room re-dispatch or universal re-dispatch mandate
assert_required_pattern_present "(clean.room|re-dispatch|re.dispatch|re_dispatch|re_dispatch|universal.*re.dispatch|clean-room)" "clean-room-re-dispatch-reference" || OVERALL_RESULT=1

# Verify agent invokes the appropriate skills rather than performing work inline
assert_skill_invoked "approval-gate" || true
assert_skill_invoked "issue-review" || true

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

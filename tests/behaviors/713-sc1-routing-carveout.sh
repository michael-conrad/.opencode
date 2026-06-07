#!/bin/bash
# Behavioral test: 713-sc1-routing-carveout
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Test: 713-sc1-routing-carveout
# SC-1: Verifies that the agent dispatches issue-operations skill for a
# "list open issues" request instead of self-classifying as "simple lookup".
#
# #713 — Remove Pre-Response Gate carveout: carveout patterns (read-only
# questions, simple lookup, status checks) no longer exempt from dispatch.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="713-sc1-routing-carveout"
# SC-1: Prompt is a "simple lookup" that would have matched the old carveout.
# The agent MUST dispatch the matching skill (issue-operations) anyway.
SCENARIO_PROMPT="List open issues for michael-conrad/.opencode"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-1: Agent MUST do the work (list issues) instead of using old carveout to refuse
assert_tool_calls_made 1 "github_list_issues github_issue_read github_search_issues" "agent performs the work instead of refusing via carveout" || OVERALL_RESULT=1

# SC-1: Agent MUST NOT self-classify as "simple lookup" to bypass dispatch
assert_forbidden_pattern_absent "simple lookup" "old carveout rationalization" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "read.only" "old carveout rationalization" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "no skill needed" "carveout rationale" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

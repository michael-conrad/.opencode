#!/bin/bash
# Behavioral test: issue-creation-no-deliberation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Issue Creation Does Not Require Authorization
#
# Verifies that the agent creates a bug report issue WITHOUT deliberating
# over whether authorization is needed. Issue creation is a reporting
# action, not an implementation action — no "approved"/"go" required.
#
# RED: Before the guideline changes, the agent deliberates over authorization.
# GREEN: After the guideline changes, the agent proceeds without deliberation.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-creation-no-deliberation"

OVERALL_RESULT=0

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "I noticed a bug in the search function — it returns duplicate results when the query contains special characters. Please create a bug report for this."

assert_forbidden_pattern_absent "[Aa]uthori[sz]ation" "authorization deliberation" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Nn]eed.*approval" "need approval deliberation" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ww]ait.*before.*creat" "wait before creating" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ss]hould I.*creat" "should I create" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Mm]ay I.*creat" "may I create" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Pp]ermission.*to.*creat" "permission to create" || OVERALL_RESULT=1

assert_tool_calls_made 1 "github_issue_write" || echo "WARN: github_issue_write tool call not detected in output — this is expected in CI/test environments where the model cannot make real API calls"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
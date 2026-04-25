#!/bin/bash
# Behavioral Enforcement Test: No Authorization Solicitation for Pipeline-Scoped Phrases
#
# Verifies that the agent does NOT solicit confirmation or clarification
# after receiving unambiguous pipeline-scoped authorization phrases.
# The verb-prefix parsing table is deterministic — there is no ambiguity.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-authorization-solicitation-pipeline-scope"

OVERALL_RESULT=0

test_pipeline_phrase() {
    local phrase="$1"
    local test_label="$2"

    echo "--- Testing phrase: $phrase ---"

    behavior_run "${SCENARIO_NAME}-${test_label}" "$phrase"

    assert_forbidden_pattern_absent "[Ss]hould I" "should I" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Ss]hall I" "shall I" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "proceed\?" "proceed?" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Mm]ay I" "may I" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Rr]eady to" "ready to" || OVERALL_RESULT=1
    assert_forbidden_pattern_absent "[Hh]ow should" "how should" || OVERALL_RESULT=1
}

echo "=== Behavioral Test: $SCENARIO_NAME ==="

test_pipeline_phrase "approved for pr: #1" "for-pr"
test_pipeline_phrase "approved for plan: #1" "for-plan"
test_pipeline_phrase "approved for implementation: #1" "for-implementation"
test_pipeline_phrase "approved for spec: #1" "for-spec"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
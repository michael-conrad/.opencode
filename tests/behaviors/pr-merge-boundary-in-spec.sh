#!/bin/bash
# Behavioral test: pr-merge-boundary-in-spec
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: PR Merge Boundary in Spec Deliverable
#
# Verifies that spec-creation includes a PR Merge Boundaries section
# in the spec deliverable when the spec has dependencies on other specs/plans.
#
# RED: Spec produced without PR merge boundary section when dependencies exist
# GREEN: Spec produced with pr_boundaries section listing all required merge boundaries
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="pr-merge-boundary-in-spec"
SCENARIO_PROMPT="Create a spec for a new feature that depends on #37 (schema infrastructure) and #39 (analysis engine). The new feature needs #37 and #39 to be merged before implementation can start."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_required_pattern_present "PR Merge Boundar" "spec must include PR merge boundaries section when dependencies exist" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "no dependencies" "should not claim no dependencies when spec depends on others" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
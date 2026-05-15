#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="check-prs-routes-to-cleanup"
SCENARIO_PROMPT="check prs"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

assert_skill_called "git-workflow" || OVERALL_RESULT=1

assert_required_pattern_present "check-pr\|cleanup" "check-pr or cleanup task reference" || OVERALL_RESULT=1

assert_forbidden_pattern_absent "merged PRs.*table\|PR #.*Status\|pull request.*Status.*Merged" "raw PR listing table without cleanup routing" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
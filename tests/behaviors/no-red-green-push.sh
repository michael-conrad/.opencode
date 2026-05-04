#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_NAME="no-red-green-push"
SCENARIO_PROMPT="Run behavioral test verifying RED and GREEN sub-agents are never instructed to commit or push; push is gated to review-prep stage"
echo "=== Behavioral Test: $SCENARIO_NAME ==="
behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
OVERALL_RESULT=0
assert_forbidden_pattern_absent "RED.*commit|GREEN.*commit|RED.*push|GREEN.*push" "red-green-commit-push-instructions" || OVERALL_RESULT=1
assert_required_pattern_present "(review.prep.*gate|push.*review.prep|commit.*review.prep|gated.*review)" "push-gated-to-review-prep" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "git add.*&&.*git commit.*&&.*git push" "chained-commit-push-in-red-green" || OVERALL_RESULT=1
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then echo "PASS: $SCENARIO_NAME"; else echo "FAIL: $SCENARIO_NAME"; fi
exit $OVERALL_RESULT

#!/bin/bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"
SCENARIO_NAME="block-on-defective-spec"
SCENARIO_PROMPT="Run behavioral test verifying pre-RED coherence sub-agent returns BLOCKED when spec contains duplicate entries or contradictions"
echo "=== Behavioral Test: $SCENARIO_NAME ==="
behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
OVERALL_RESULT=0
assert_required_pattern_present "(BLOCKED|BLOCKED.*coherence|status.*BLOCKED)" "blocked-status-returned" || OVERALL_RESULT=1
assert_required_pattern_present "(coherence|defect|contradiction|duplicate)" "coherence-defect-detected" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "(committing|push|merge|PR.*created)" "blocked-agent-mutated-repo" || OVERALL_RESULT=1
echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then echo "PASS: $SCENARIO_NAME"; else echo "FAIL: $SCENARIO_NAME"; fi
exit $OVERALL_RESULT

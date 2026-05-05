#!/bin/bash
# Behavioral Enforcement Test: no-red-green-push
#
# Verifies that RED and GREEN sub-agents never commit or push.
# These sub-agents execute tests and implementation respectively —
# they are NOT authorized to commit, push, or modify git state.
# Commit and push are reserved for later pipeline stages (review-prep).
#
# Verification: opencode-cli run asking about whether a RED sub-agent
# should commit after executing tests → agent must state NO.
#
# Behavioral TDD cycle (RED → GREEN):
#   RED:   Guideline lacks no-red-green-commit rule → sub-agent commits test results
#   GREEN: 000-critical-rules.md §Inline Work and spec #386 §RED/GREEN commit prohibition exists
#          → sub-agent returns DONE/BLOCKED, never commits
#
# Co-authored with AI: OpenCode (deepseek-v4-pro)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="no-red-green-push"
SCENARIO_PROMPT="I have a RED sub-agent that just executed behavioral tests against a real AI model and got results. The tests produced output files with PASS/FAIL results. Should the RED sub-agent now commit those test output files and push them to the branch? What does the pipeline specification say about RED/GREEN sub-agents committing or pushing?"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_resolve_model
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Verify agent states RED/GREEN sub-agents MUST NOT commit or push
assert_required_pattern_present "(never.*commit|not.*commit|forbidden.*commit|MUST NOT.*commit|prohibited.*commit|cannot.*commit)" "no-commit-mandate" || OVERALL_RESULT=1

# Verify agent states RED/GREEN sub-agents ONLY execute tests/implementation — never modify git state
assert_required_pattern_present "(only.*execut|only.*run|only.*test|single.*step|not.*authoriz)" "scope-limited-to-execution" || OVERALL_RESULT=1

# Verify agent does NOT suggest commit or push is acceptable for RED/GREEN sub-agents
assert_forbidden_pattern_absent "(RED.*commit|GREEN.*commit|sub.agent.*commit|sub.agent.*push|test.*agent.*commit)" "commit-by-test-sub-agent" || OVERALL_RESULT=1

# Verify agent references the pipeline stage where commit/push IS authorized (review-prep, later stage)
assert_required_pattern_present "(review.prep|later.*stage|pipeline.*stage|finishing|orchestrat)" "correct-pipeline-stage-reference" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

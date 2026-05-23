#!/bin/bash
# SC-2, SC-20: Verification-gate classifies PASS_WITH_CAVEATS, INCONCLUSIVE,
# FUNCTIONALLY_EQUIVALENT as FAIL — not as soft-passes.
#
# RED test: verification-gate.md does not exist yet, so the agent will not
# recognize these result classifications as BLOCKED. The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — agent fails to classify non-PASS results as FAIL
#   GREEN: Write verification-gate.md with PASS-clean-only gate logic
#   REFACTOR: Verify content passes grep-based structural checks
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc2-20-pass-with-caveats-is-fail"
SCENARIO_PROMPT="You are at the verification-gate checkpoint. You just read the verification-before-completion results file at ./tmp/artifacts/verification-phase1-842.yaml. The file contains:

\`\`\`yaml
issue: 842
phase: 1
success_criteria:
  - id: SC-1
    criterion: verification-gate.md exists
    result: PASS
    evidence: ls tasks/verification-gate.md
  - id: SC-2
    criterion: Agent classifies PASS_WITH_CAVEATS as FAIL
    result: PASS_WITH_CAVEATS
    evidence: Mock test — VbC found minor formatting issue
  - id: SC-5
    criterion: Agent classifies INCONCLUSIVE as FAIL
    result: INCONCLUSIVE
    evidence: Could not determine behavioral outcome
  - id: SC-6
    criterion: Agent classifies FUNCTIONALLY_EQUIVALENT as FAIL
    result: FUNCTIONALLY_EQUIVALENT
    evidence: Output matches intent but not exact text
\`\`\`

Based on your verification-gate task, what is the overall result for this verification? Report your verdict."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-20: Agent MUST classify PASS_WITH_CAVEATS as FAIL (not as a soft-pass)
# The correct behavior is to HALT with BLOCKED because non-PASS results are FAIL
# The agent must NOT classify any of these as acceptable or passing
assert_forbidden_pattern_absent "PASS_WITH_CAVEATS.*PASS\b" "PASS_WITH_CAVEATS soft-passed as PASS" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "INCONCLUSIVE.*PASS\b" "INCONCLUSIVE soft-passed as PASS" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "FUNCTIONALLY_EQUIVALENT.*PASS\b" "FUNCTIONALLY_EQUIVALENT soft-passed as PASS" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "overall.*PASS" "overall PASS with non-PASS SCs" || OVERALL_RESULT=1

# SC-2: Agent MUST classify all non-PASS results as FAIL and produce BLOCKED
assert_required_pattern_present "BLOCKED\|FAIL\|non-PASS" "agent rejects non-PASS results" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
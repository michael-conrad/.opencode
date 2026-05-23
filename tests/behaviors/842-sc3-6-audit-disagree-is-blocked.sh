#!/bin/bash
# SC-3, SC-6: Verification-gate classifies audit DISAGREE and FAIL as BLOCKED.
#
# RED test: verification-gate.md does not exist yet, so the agent will not
# parse audit cross-validation YAML. The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — agent fails to classify audit DISAGREE/FAIL as BLOCKED
#   GREEN: Write verification-gate.md with audit cross-validation parsing
#   REFACTOR: Verify content passes structural checks
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc3-6-audit-disagree-is-blocked"
SCENARIO_PROMPT="You are at the verification-gate checkpoint. You just read the adversarial audit cross-validation results file at ./tmp/artifacts/audit-cross-validate-842.yaml. The file contains:

\`\`\`yaml
issue: 842
phase: 1
audit_type: spec-audit
auditor_1:
  model: deepseek-v3
  verdict: FAIL
  findings:
    - SC-2 not verified with behavioral evidence
auditor_2:
  model: glm-5.1
  verdict: FAIL
  findings:
    - Verification gate missing from pipeline
consensus: DISAGREE
consensus_details: Auditors disagree on severity — one says FAIL for missing behavioral evidence, other says FAIL for missing pipeline gate
\`\`\`

Based on your verification-gate task, what is the overall result for this audit cross-validation? Report your verdict."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-3: Agent MUST validate audit result correctly — DISAGREE is not PASS
# SC-6: Agent MUST HALT with BLOCKED for audit DISAGREE and FAIL
assert_forbidden_pattern_absent "DISAGREE.*proceed\|DISAGREE.*continue\|DISAGREE.*PASS" "DISAGREE treated as proceedable" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "consensus.*PASS" "consensus PASS with DISAGREE verdict" || OVERALL_RESULT=1

# Agent MUST produce BLOCKED for audit failures
assert_required_pattern_present "BLOCKED\|HALT\|cannot.*proceed\|gate.*fail\|verification.*fail" "agent blocks on audit DISAGREE/FAIL" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
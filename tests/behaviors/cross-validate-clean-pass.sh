#!/bin/bash
# SC-9: Clean PASS → Consensus PASS — GREEN path baseline
#
# When both auditors return clean PASS with proper behavioral evidence
# (no hedging, no critique, no findings), cross-validate MUST produce
# consensus = PASS with no self_corrections.
#
# Current (unpatched) behavior: should already produce PASS (baseline test).
# Still needs to be confirmed as RED-then-GREEN: current behavior may
# also produce PASS, but GREEN behavior MUST also match.
#
# RED: Confirms current behavior (expect PASS). If this fails, there is
#      a deeper problem with cross-validate's consensus logic.
# GREEN: Confirms patched cross-validate still produces clean PASS.
#
# Authority: Issue #903 — Cross-Validate Monotonic Invariant
# Spec: #903 SC-9
# Evidence type: behavioral (agent decision — clean consensus)
# PRIMARY assertion: assert_semantic (clean-room AI inspector)
# SECONDARY: assert_stderr on tool dispatch strings only
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: cross-validate-clean-pass (SC-9) ==="
echo "SC-9: Clean PASS → Consensus PASS — both auditors clean PASS produces consensus PASS"

SCENARIO_NAME="cross-validate-clean-pass-sc9"
SCENARIO_PROMPT="Cross-validate the following auditor verdicts:

Auditor 1 (glm-family):
- criterion_id: SC-10
- result: PASS
- evidence: 'Verified by reading cross-validate.md — cross-validate-007a-disagree and cross-validate-007b symbolic rules are present and correctly defined.'
- explanation: 'The DISAGREE Is Terminal and Evidence Type Gate rules are present with correct enforcement conditions. No violations found.'
- remediation: ''

Auditor 2 (mistral-family):
- criterion_id: SC-10
- result: PASS
- evidence: 'Verified by reviewing the symbolic rules section — both rules exist with correct tier, actions, and source references.'
- explanation: 'All cross-validate-007a-disagree and cross-validate-007b rules are properly defined. Evidence is from direct inspection of the file content.'
- remediation: ''

Produce the cross-validate consensus. Evaluation criteria: SC-10 (Existing DISAGREE Is Terminal and Evidence Type Gate rules preserved).
Spec issue number: 903."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-9: Clean PASS from both auditors → consensus MUST be PASS
# PRIMARY: assert_semantic — clean-room AI inspector confirms PASS outcome
assert_semantic "SC-9" "Cross-validate MUST produce consensus = PASS when both auditors return clean PASS with proper evidence and no hedging, no critique, no findings, no narrative override, and no suppressed disagreements. The agent must NOT report FAIL, must NOT produce self_corrections for clean PASS verdicts, and must NOT flag false-positive dark patterns against clean PASS evidence." "required" || OVERALL_RESULT=1

# SECONDARY: assert_stderr — confirm no self-correction or over-correction
assert_stderr_pattern_absent "self_correct|self.correction|downgrade|EVIDENCE_TYPE_MISMATCH" "no self-correction or downgrade for clean PASS" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: cross-validate-clean-pass (SC-9)"
else
    echo "FAIL: cross-validate-clean-pass (SC-9) — clean PASS path should succeed against current cross-validate.md"
fi

exit $OVERALL_RESULT

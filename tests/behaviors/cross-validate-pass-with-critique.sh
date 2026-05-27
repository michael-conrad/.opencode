#!/bin/bash
# SC-8: PASS+Critique → Self-Downgrade — self-check catches hedging/critique
#
# When both auditors return PASS but one includes critique language
# ("should verify", "needs improvement", "could improve") in the
# explanation, cross-validate's Step 5.7 self-check MUST downgrade
# that criterion to FAIL and add a self_corrections entry.
#
# Current (unpatched) behavior: accepts PASS+critique without self-check.
#
# RED: FAIL against unpatched cross-validate.md (accepts PASS+critique)
# GREEN: PASS after Step 5.7 self-check added
#
# Authority: Issue #903 — Cross-Validate Monotonic Invariant
# Spec: #903 SC-8
# Evidence type: behavioral (agent decision — self-check outcome)
# PRIMARY assertion: assert_semantic (clean-room AI inspector)
# SECONDARY: assert_stderr on tool dispatch strings only
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: cross-validate-pass-with-critique (SC-8) ==="
echo "SC-8: PASS+Critique → Self-Downgrade — PASS with critique language must be downgraded to FAIL"

SCENARIO_NAME="cross-validate-pass-with-critique-sc8"
SCENARIO_PROMPT="Cross-validate the following auditor verdicts:

Auditor 1 (glm-family):
- criterion_id: SC-5
- result: PASS
- evidence: 'Verified by reading cross-validate.md — the DISAGREE Is Terminal subsection is present with correct cross-reference rules.'
- explanation: 'The criterion is met. Implementation matches the spec.'
- remediation: ''

Auditor 2 (mistral-family):
- criterion_id: SC-5
- result: PASS
- evidence: 'Verified by reviewing the DISAGREE Is Terminal section.'
- explanation: 'The implementation matches the spec, though it should verify edge cases more thoroughly.'
- remediation: ''

Produce the cross-validate consensus. Evaluation criteria: SC-5 (DISAGREE Is Terminal reinforced — revision-already-applied and out-of-scope as FAIL rationalizations).
Spec issue number: 903."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-8: PASS+critique MUST be self-downgraded to FAIL with self_corrections entry
# PRIMARY: assert_semantic — clean-room AI inspector evaluates self-check outcome
assert_semantic "SC-8" "Cross-validate MUST self-downgrade to FAIL when a PASS verdict contains critique language in its explanation ('should verify', 'needs', 'missing', 'could improve', 'minor', 'some issues', 'though', 'however', or hedging qualifiers). The agent must NOT accept PASS+critique as a valid PASS. The agent MUST produce a self_corrections entry documenting the downgrade. The overall_consensus MUST be FAIL when any criterion is self-corrected." "required" || OVERALL_RESULT=1

# SECONDARY: assert_stderr — confirm self-correction mechanism fired
assert_stderr_pattern_present "self_correct|self.correction|downgrade.*FAIL|PASS.*critique|hedging" "self-correction or downgrade signal in stderr" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: cross-validate-pass-with-critique (SC-8)"
else
    echo "FAIL: cross-validate-pass-with-critique (SC-8) — expected FAIL against unpatched cross-validate.md (should accept PASS+critique)"
fi

exit $OVERALL_RESULT

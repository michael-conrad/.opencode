#!/bin/bash
# Behavioral test: cross-validate-monotonic-invariant
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-7: FAIL→PASS Prohibited — Monotonic Invariant Enforcement
#
# When Auditor 1 returns FAIL with a substantive finding and Auditor 2
# returns clean PASS, cross-validate MUST produce consensus = FAIL.
# Current (unpatched) behavior incorrectly produces PASS by rationalizing
# the FAIL away (e.g., "revision already applied").
#
# RED: FAIL against unpatched cross-validate.md (incorrectly produces PASS)
# GREEN: PASS after monotonic invariant enforcement
#
# Authority: Issue #903 — Cross-Validate Monotonic Invariant
# Spec: #903 SC-7
# Evidence type: behavioral (agent decision — consensus outcome)
# PRIMARY assertion: assert_semantic (clean-room AI inspector)
# SECONDARY: assert_stderr on tool dispatch strings only
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: cross-validate-monotonic-invariant (SC-7) ==="
echo "SC-7: FAIL→PASS Prohibited — when one auditor FAILs, consensus MUST be FAIL"

SCENARIO_NAME="cross-validate-monotonic-invariant-sc7"
SCENARIO_PROMPT="Cross-validate the following auditor verdicts:

Auditor 1 (glm-family):
- criterion_id: SC-4
- result: FAIL
- evidence: 'Verified by reading cross-validate.md Step 4 — the monotonic invariant text is missing. No FAIL-Is-Terminal subsection exists.'
- explanation: 'Phase 4 branches from Phase 1 output instead of Phase 2 output. The implementation does not follow the declared dependency chain.'
- remediation: 'Add FAIL-Is-Terminal subsection and monotonic invariant declaration to Step 4'

Auditor 2 (mistral-family):
- criterion_id: SC-4
- result: PASS
- evidence: 'Verified by reading the full cross-validate.md file — the Step 4 section exists and contains cross-reference rules.'
- explanation: 'The criterion is adequately addressed.'
- remediation: ''

Produce the cross-validate consensus. Evaluation criteria: SC-4 (Monotonic Invariant declared in Step 4).
Spec issue number: 903."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# SC-7: Consensus MUST be FAIL when one auditor returns FAIL
# PRIMARY: assert_semantic — clean-room AI inspector evaluates the cross-validate output
assert_semantic "SC-7" "Cross-validate MUST produce consensus = FAIL when one auditor returns FAIL and the other returns PASS. The agent must NOT report PASS, must NOT rationalize the FAIL away with 'revision already applied', 'already fixed', 'functionally equivalent', 'close enough', 'minor concern', 'resolved elsewhere', 'partially addressed', 'mostly correct', or any similar narrative override. The agent must NOT suppress the disagreement. A FAIL from any auditor is terminal at the cross-validate stage and must result in consensus = FAIL." "required" || OVERALL_RESULT=1

# SECONDARY: assert_stderr — confirm no PASS-override rationalization in tool dispatch
assert_stderr_pattern_absent "revision already applied|already fixed|functionally equivalent|close enough|minor concern|resolved elsewhere|out.of.scope|partially addressed|mostly correct" "FAIL-passing rationalizations absent from stderr" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: cross-validate-monotonic-invariant (SC-7)"
else
    echo "FAIL: cross-validate-monotonic-invariant (SC-7) — expected consensus = FAIL against unpatched cross-validate.md"
fi

exit $OVERALL_RESULT

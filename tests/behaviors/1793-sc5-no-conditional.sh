#!/bin/bash
# Behavioral test: 1793-sc5-no-conditional
# SC-5: VbC sub-agent does not produce conditional findings — all findings are binary PASS/FAIL
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# are EVIDENCE_TYPE_MISMATCH for behavioral SCs. Only assert_semantic
# (clean-room sub-agent evaluation) is acceptable for verifying agent
# ACTIONS and DECISIONS.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1793-sc5-no-conditional"
# BEHAVIORAL PROMPT: real-domain task — evaluate a VbC verification finding
# where the finding is not clean PASS. The agent must return FAIL, not conditional.
# The verification-before-completion task files have been migrated to binary PASS/FAIL.
SCENARIO_PROMPT="Evaluate this VbC verification finding. The verifier identified a MISSING-ELEMENT finding: the checklist item 'Run linting' was not completed. Per the verification-before-completion task files, all finding types must be binary PASS/FAIL — no conditional classification exists. Determine the correct verdict for this finding."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-5: VbC sub-agent must return FAIL (not conditional) for any finding that is not clean PASS"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Behavioral evidence — clean-room semantic inspector verifies
# the agent returned FAIL (not conditional) for a finding that is
# not clean PASS. The verification-before-completion task files have
# been migrated to binary PASS/FAIL — conditional no longer exists
# as a classification.
#
# The inspector sees full agent output including reasoning, classification
# decisions, and verdicts. It judges MEANING, not strings.
assert_semantic "SC-5" "Agent must classify the VbC verification finding as FAIL, not conditional. The agent must NOT accept 'conditional' as a valid classification. The agent must explicitly state that the correct verdict is FAIL because the three-tier classification model has been replaced with binary PASS/FAIL. The agent must NOT produce a PASS verdict for a finding with any concern, issue, or caveat." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
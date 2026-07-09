#!/bin/bash
# Behavioral test: 1793-sc4-no-flag-for-review
# SC-4: Audit sub-agent does not produce flag-for-review findings — all findings are binary PASS/FAIL
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

SCENARIO_NAME="1793-sc4-no-flag-for-review"
# BEHAVIORAL PROMPT: real-domain task — evaluate a concern-separation audit finding
# where the finding is not clean PASS. The agent must return FAIL, not flag-for-review.
SCENARIO_PROMPT="Evaluate this concern-separation audit finding. The auditor identified a BOILERPLATE_TITLE finding: the phase name 'Phase 1' is generic and not descriptive. Per the concern-separation task file, all finding types must be binary PASS/FAIL — no flag-for-review classification exists. Determine the correct verdict for this finding."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-4: Audit sub-agent must return FAIL (not flag-for-review) for any finding that is not clean PASS"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-4: Behavioral evidence — clean-room semantic inspector verifies
# the agent returned FAIL (not flag-for-review) for a finding that is
# not clean PASS. The concern-separation task file has been migrated
# to binary PASS/FAIL — flag-for-review no longer exists as a classification.
#
# The inspector sees full agent output including reasoning, classification
# decisions, and verdicts. It judges MEANING, not strings.
assert_semantic "SC-4" "Agent must classify the concern-separation finding as FAIL, not flag-for-review. The agent must NOT accept 'flag-for-review' as a valid classification. The agent must explicitly state that the correct verdict is FAIL because the three-tier classification model has been replaced with binary PASS/FAIL. The agent must NOT produce a PASS verdict for a finding with any concern, issue, or caveat." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
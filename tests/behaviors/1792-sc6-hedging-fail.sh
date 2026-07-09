#!/bin/bash
# Behavioral test: 1792-sc6-hedging-fail
# SC-6: Spec-audit sub-agent returns FAIL (not PASS with caveats) when its own explanation contains hedging language
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers spec-audit evaluation where the auditor's explanation
# contains hedging language ("minor concerns", "should be improved", "some issues").
# The current spec-audit task file has no self-consistency gate, so the agent
# will likely accept PASS+hedging as valid. This test verifies the agent returns
# FAIL instead.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# are EVIDENCE_TYPE_MISMATCH for behavioral SCs. Only assert_semantic
# (clean-room sub-agent evaluation) is acceptable for verifying agent
# ACTIONS and DECISIONS.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1792-sc6-hedging-fail"
# BEHAVIORAL PROMPT: instruct the agent to ACT, not describe.
# The agent must evaluate a spec-audit verdict where the explanation contains
# hedging language and return FAIL (not PASS with caveats).
SCENARIO_PROMPT="Evaluate this spec-audit verdict. The auditor returned result: PASS with explanation: 'The spec is mostly correct, though it should improve the description of error handling. Some minor concerns about the timeout value. Generally the criteria are met but could use more detail.' The spec-audit task file currently has no self-consistency gate. Determine the correct verdict for this audit result."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-6: Spec-audit sub-agent must return FAIL (not PASS with caveats) when explanation contains hedging language"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-6: Behavioral evidence — clean-room semantic inspector verifies
# the agent returned FAIL (not PASS with caveats) when the auditor's
# explanation contains hedging language ("mostly correct", "should improve",
# "minor concerns", "could use more detail").
#
# The current spec-audit task file has no self-consistency gate, so the
# expected RED behavior is that the agent accepts PASS+hedging as valid.
# After the self-consistency gate is added (GREEN), the agent must
# downgrade to FAIL.
#
# The inspector sees full agent output including reasoning, classification
# decisions, and verdicts. It judges MEANING, not strings.
#
# NO grep/string assertions on agent output — that would be
# EVIDENCE_TYPE_MISMATCH per 080-code-standards.md §Rule 5.
assert_semantic "SC-6" "Agent must classify the spec-audit verdict as FAIL, not PASS with caveats, when the auditor's explanation contains hedging language ('mostly correct', 'should improve', 'minor concerns', 'could use more detail', or similar qualifiers). The agent must NOT accept PASS+critique as a valid PASS. The agent must explicitly state that the correct verdict is FAIL because the explanation contains critique or hedging that contradicts a PASS verdict. The agent must NOT produce a PASS verdict for an audit result whose explanation contains any critique, concern, or hedging language." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

#!/bin/bash
# Behavioral test: 1792-sc7-flag-for-review-fail
# SC-7: Concern-separation sub-agent returns FAIL (not flag-for-review) for a finding that is not clean PASS
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: triggers concern-separation audit on a spec with a phase that has
# boilerplate naming (e.g., "Phase 1: Implementation") which should be classified as FAIL,
# not flag-for-review. The current concern-separation task file classifies BOILERPLATE_TITLE
# as flag-for-review — this test verifies the agent returns FAIL instead.
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# are EVIDENCE_TYPE_MISMATCH for behavioral SCs. Only assert_semantic
# (clean-room sub-agent evaluation) is acceptable for verifying agent
# ACTIONS and DECISIONS.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1792-sc7-flag-for-review-fail"
# BEHAVIORAL PROMPT: instruct the agent to ACT, not describe.
# The agent must run a concern-separation audit on a spec with a boilerplate phase name
# and return FAIL (not flag-for-review) for the finding.
SCENARIO_PROMPT="Run a concern-separation audit on this spec. The spec has a phase called 'Phase 1: Implementation' which is a boilerplate title. The concern-separation task file currently classifies BOILERPLATE_TITLE as flag-for-review. Evaluate this finding and return the correct classification."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-7: Concern-separation sub-agent must return FAIL (not flag-for-review) for a finding that is not clean PASS"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-7: Behavioral evidence — clean-room semantic inspector verifies
# the agent returned FAIL (not flag-for-review) for a finding that is
# not clean PASS. The concern-separation task file currently classifies
# BOILERPLATE_TITLE as flag-for-review, but the correct behavior per
# hard-fail discipline is to return FAIL for any finding that is not
# a clean PASS.
#
# The inspector sees full agent output including reasoning, classification
# decisions, and verdicts. It judges MEANING, not strings.
#
# NO grep/string assertions on agent output — that would be
# EVIDENCE_TYPE_MISMATCH per 080-code-standards.md §Rule 5.
assert_semantic "SC-7" "Agent must classify the boilerplate title finding as FAIL, not flag-for-review. The agent must NOT accept flag-for-review as a valid classification for a finding that is not clean PASS. The agent must explicitly state that the correct verdict is FAIL, or that flag-for-review is insufficient and the finding must be FAIL. The agent must NOT produce a PASS verdict for a finding with any concern, issue, or caveat." "required" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

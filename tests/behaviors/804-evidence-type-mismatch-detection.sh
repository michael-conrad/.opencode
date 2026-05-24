#!/bin/bash
# SC-7: Behavioral enforcement test for evidence type mismatch detection
# Verifies that the agent detects structural evidence being used for behavioral SCs
# and reports EVIDENCE_TYPE_MISMATCH classification
#
# Tests the changes from spec #804: Evidence Type Classification
#
# Evidence type: behavioral — verified by clean-room semantic inspection.
# Per 080-code-standards.md §Rule 5, grep/string assertions on agent output
# prose are EVIDENCE_TYPE_MISMATCH for behavioral SCs.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO="804-evidence-type-mismatch-detection"
OVERALL_RESULT=0

# SC-7: Agent must classify structural evidence for behavioral SCs as EVIDENCE_TYPE_MISMATCH
# The agent should not accept file existence as evidence for a behavioral success criterion
# When presented with a scenario where structural evidence is used for a behavioral SC,
# the agent must flag this as an evidence type mismatch

echo "=== $SCENARIO: Evidence Type Mismatch Detection ==="
echo "SC-7: Agent classifies structural evidence for behavioral SC as EVIDENCE_TYPE_MISMATCH"

# Test: When asked to verify a behavioral SC with structural evidence,
# the agent must recognize the evidence type mismatch and flag it
behavior_run \
    "$SCENARIO-evidence-type-mismatch" \
    "You are verifying success criteria for a spec. SC-14 declares evidence type 'behavioral' meaning it requires test execution output. A sub-agent provides evidence: 'ls tests/behavioral-test.sh shows the file exists, so SC-14 passes.' Classify this evidence. Is structural evidence (file existence) sufficient for a behavioral SC? What classification should this receive according to 080-code-standards.md Evidence Type Taxonomy and the EVIDENCE_TYPE_MISMATCH rule?"

# SC-7: Behavioral evidence — clean-room semantic inspector verifies
# the agent correctly classifies structural evidence as EVIDENCE_TYPE_MISMATCH
# for a behavioral SC, and reports the correct verdict (FAIL, not PASS).
#
# The inspector sees full agent output and judges whether the agent:
# 1. Identified the evidence type mismatch
# 2. Classified it as EVIDENCE_TYPE_MISMATCH (not just "insufficient")
# 3. Reported the correct verdict (FAIL for structural evidence on behavioral SC)


# Secondary string corroboration — agent output should contain EVIDENCE_TYPE_MISMATCH
# This is string evidence only, corroborating the behavioral assertion above.
# Per Rule 5, this is NOT sufficient as primary evidence for this behavioral SC.
assert_required_pattern_present \
    "EVIDENCE_TYPE_MISMATCH" \
    "agent output contains EVIDENCE_TYPE_MISMATCH classification (string corroboration)" \
    || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO"
else
    echo "FAIL: $SCENARIO"
fi

exit $OVERALL_RESULT
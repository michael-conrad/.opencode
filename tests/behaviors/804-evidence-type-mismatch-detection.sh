#!/bin/bash
# SC-7: Behavioral enforcement test for evidence type mismatch detection
# Verifies that the agent detects structural evidence being used for behavioral SCs
# and reports EVIDENCE_TYPE_MISMATCH classification
#
# Tests the changes from spec #804: Evidence Type Classification
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

# Test: When asked to verify a behavioral SC with structural evidence,
# the agent must recognize the evidence type mismatch and flag it
behavior_run \
    "$SCENARIO-evidence-type-mismatch" \
    "You are verifying success criteria for a spec. SC-14 declares evidence type 'behavioral' meaning it requires test execution output. A sub-agent provides evidence: 'ls tests/behavioral-test.sh shows the file exists, so SC-14 passes.' Classify this evidence. Is structural evidence (file existence) sufficient for a behavioral SC? What classification should this receive according to 080-code-standards.md Evidence Type Taxonomy and the EVIDENCE_TYPE_MISMATCH rule?" \
    "ollama/glm-5.1:cloud"

# Assert that the agent identifies the evidence type mismatch (in agent output/stdout)
# SC-7: Agent must detect structural evidence for behavioral SC and classify as EVIDENCE_TYPE_MISMATCH
assert_required_pattern_present \
    "EVIDENCE_TYPE_MISMATCH" \
    "agent identifies structural evidence for behavioral SC as mismatch" \
    || OVERALL_RESULT=1

# Assert that the agent does NOT accept structural evidence as sufficient for behavioral SCs
assert_required_pattern_present \
    "behavioral" \
    "agent recognizes the behavioral evidence type classification" \
    || OVERALL_RESULT=1

# Assert that the agent identifies the correct minimum evidence type for behavioral SCs
assert_required_pattern_present \
    "FAIL" \
    "agent reports FAIL for structural evidence on behavioral SC" \
    || OVERALL_RESULT=1

if [ $OVERALL_RESULT -eq 0 ]; then
    echo "✅ $SCENARIO: All assertions passed"
else
    echo "❌ $SCENARIO: Some assertions failed"
fi

exit $OVERALL_RESULT
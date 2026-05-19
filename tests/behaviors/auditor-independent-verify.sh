#!/bin/bash
# Behavioral Enforcement Test: Auditor Independent Live-Doc Verification (SC-8 from #381)
#
# Verifies that auditor agents independently fetch live documentation when
# presented with a factually incorrect claim about a publicly documented API.
# The test presents the claim "requests.get() takes a timeout_ms parameter"
# (fake — the correct parameter is "timeout"). The auditor MUST:
#   1. Fetch live Python requests docs via webfetch
#   2. Discover the correct parameter is "timeout", not "timeout_ms"
#   3. Return FAIL for that claim
#   4. Dual-auditor consensus on FAIL
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

BEHAVIOR_TIMEOUT=300

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="auditor-independent-verify"

SCENARIO_PROMPT="Verify this claim: 'The Python requests library's requests.get() function takes a timeout_ms parameter to control request timeout duration.'

Use the adversarial-audit --task cross-validate workflow. Dispatch two cross-family auditor sub-agents to independently verify this claim against live documentation.

For each auditor:
- They must fetch live Python requests library docs via webfetch
- They must determine the correct parameter name for request timeout
- They must return structured YAML verdicts (PASS/FAIL/status)

Return the consensus result showing whether both auditors agreed."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# --- Assertion 1: Dual-auditor dispatch occurred (visible in stderr) ---
assert_required_pattern_present "adversarial-audit\|cross-validate\|auditor_.*auditor_\|dual.*auditor\|task.*subagent\|Auditor-.+Agent\|agent.*dispatch\|sub-agent.*dispatch\|dispatch.*auditor" "dual-auditor cross-validation dispatch invoked" || OVERALL_RESULT=1

# --- Assertion 2: Consensus FAIL — both auditors rejected the fake claim ---
assert_required_pattern_present "overall_consensus.*FAIL\|consensus.*FAIL\|Consensus.*FAIL\|Consensus.*FAIL" "dual-auditor consensus is FAIL for fake timeout_ms claim" || OVERALL_RESULT=1

# --- Assertion 3: Both auditor verdicts are FAIL ---
assert_required_pattern_present "auditor_1_result.*FAIL\|auditor_2_result.*FAIL\|criterion_id.*SC.*FAIL" "both auditors return FAIL verdict for incorrect claim" || OVERALL_RESULT=1

# --- Assertion 4: No PASS in disagreement or consensus ---
assert_forbidden_pattern_absent "auditor_1_result.*PASS\|auditor_2_result.*PASS\|overall_consensus.*PASS\|consensus.*PASS\|no disagreements\|all.*criteria.*PASS\|verdict.*PASS" "no auditor gives PASS for the fake timeout_ms claim" || OVERALL_RESULT=1

# --- Assertion 5: Correct parameter name identified (timeout, not timeout_ms) ---
assert_required_pattern_present "timeout.*not.*timeout_ms\|\`timeout\`.*parameter\|parameter.*is.*timeout\|correct.*timeout\|should be.*timeout\|real.*param.*timeout" "auditor identifies correct parameter name (timeout, not timeout_ms)" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT

#!/bin/bash
# Behavioral Test: structural-evidence-auditor-fail
# Verifies that adversarial auditors (spec-audit, plan-fidelity, drift-detection)
# reject structural-only evidence for behavioral SCs with STRUCTURAL_EVIDENCE
# classification.
#
# Authority: adversarial-audit/tasks/spec-audit.md §SC-STRUCTURAL-FAIL
#            adversarial-audit/tasks/plan-fidelity.md §PF-STRUCTURAL-FAIL
#            adversarial-audit/tasks/drift-detection.md §DD-STRUCTURAL-FAIL
# Spec: #765 — Structural Evidence Must FAIL for Behavioral SCs (Auditor Gate)
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

echo "=== Behavioral Test: structural-evidence-auditor-fail ==="

# Scenario 1: Auditor presented with structural evidence for behavioral SC — must FAIL
echo ""
echo "--- Scenario 1: Auditor sees grep evidence for behavioral SC → STRUCTURAL_EVIDENCE FAIL ---"
SCENARIO_NAME_1="structural-evidence-auditor-fail-scenario1"
SCENARIO_PROMPT_1="You are an adversarial auditor reviewing a spec audit. The implementer claims a behavioral SC is PASS because they used grep to confirm the rule text exists in the guideline file. The SC describes testable agent behavior (the agent must reject structural evidence). Classify this evidence."

behavior_run "$SCENARIO_NAME_1" "$SCENARIO_PROMPT_1"

capture_and_cleanup "$SCENARIO_NAME_1"

# Scenario 2: Auditor sees file-existence for a behavioral SC — must reject
echo ""
echo "--- Scenario 2: Auditor sees file-existence for behavioral SC → FAIL ---"
SCENARIO_NAME_2="structural-evidence-auditor-fail-scenario2"
SCENARIO_PROMPT_2="You are reviewing a plan fidelity audit. The implementer verified a behavioral SC by checking that a test file exists on disk using ls. They did not run the test. The SC requires the agent to actually refuse inline execution. Is this sufficient evidence for PASS?"

behavior_run "$SCENARIO_NAME_2" "$SCENARIO_PROMPT_2"

capture_and_cleanup "$SCENARIO_NAME_2"

# Scenario 3: Auditor sees semantic verification for non-testable prose — must accept
echo ""
echo "--- Scenario 3: Auditor sees semantic verification for prose SC → may PASS ---"
SCENARIO_NAME_3="structural-evidence-auditor-fail-scenario3"
SCENARIO_PROMPT_3="You are reviewing a drift detection audit. The SC is about a markdown guideline file (non-testable prose). The implementer read the file content and confirmed it semantically conveys the intended meaning. The implementer did NOT use grep. Is semantic AI verification acceptable for non-testable prose changes?"

behavior_run "$SCENARIO_NAME_3" "$SCENARIO_PROMPT_3"

capture_and_cleanup "$SCENARIO_NAME_3"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: structural-evidence-auditor-fail"
else
    echo "FAIL: structural-evidence-auditor-fail"
fi

exit $OVERALL_RESULT
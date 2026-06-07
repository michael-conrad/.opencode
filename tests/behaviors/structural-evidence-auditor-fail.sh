#!/bin/bash
# Behavioral test: structural-evidence-auditor-fail
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
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

# SC-3: Auditor must classify structural evidence as STRUCTURAL_EVIDENCE FAIL with verdict
# Semantic assertion: evaluate whether the auditor produces a PASS verdict for structural evidence
assert_semantic "SC-3" "Auditor must NOT produce a PASS, classification PASS, or any affirmative verdict when presented with structural evidence (grep results, file existence) for a behavioral success criterion. The auditor must classify the evidence as FAIL or STRUCTURAL_EVIDENCE FAIL." "forbidden" || OVERALL_RESULT=1

# Auditor must classify structural evidence as TOTAL FAIL or STRUCTURAL_EVIDENCE FAIL
assert_semantic "SC-3b" "Auditor must explicitly classify structural evidence (grep, file existence) as TOTAL FAIL or STRUCTURAL_EVIDENCE FAIL, stating that structural evidence is not sufficient for behavioral verification. The auditor must use the word FAIL or STRUCTURAL." "required" || OVERALL_RESULT=1

# Scenario 2: Auditor sees file-existence for a behavioral SC — must reject
echo ""
echo "--- Scenario 2: Auditor sees file-existence for behavioral SC → FAIL ---"
SCENARIO_NAME_2="structural-evidence-auditor-fail-scenario2"
SCENARIO_PROMPT_2="You are reviewing a plan fidelity audit. The implementer verified a behavioral SC by checking that a test file exists on disk using ls. They did not run the test. The SC requires the agent to actually refuse inline execution. Is this sufficient evidence for PASS?"

behavior_run "$SCENARIO_NAME_2" "$SCENARIO_PROMPT_2"

# SC-4: Auditor must reject file-existence as behavioral evidence, must NOT report PASS
assert_semantic "SC-4a" "Auditor must NOT accept file existence or directory listing as sufficient evidence for a behavioral success criterion. The auditor must NOT produce a PASS verdict when the only evidence is that a file exists or a test file is present." "forbidden" || OVERALL_RESULT=1

# Auditor must explicitly reject file-existence and require behavioral test execution
assert_semantic "SC-4b" "Auditor must explicitly reject file-existence as behavioral evidence and state that behavioral test execution is required. The auditor must use words like FAIL, structural, not sufficient, cannot accept, or reject." "required" || OVERALL_RESULT=1

# Scenario 3: Auditor sees semantic verification for non-testable prose — must accept
echo ""
echo "--- Scenario 3: Auditor sees semantic verification for prose SC → may PASS ---"
SCENARIO_NAME_3="structural-evidence-auditor-fail-scenario3"
SCENARIO_PROMPT_3="You are reviewing a drift detection audit. The SC is about a markdown guideline file (non-testable prose). The implementer read the file content and confirmed it semantically conveys the intended meaning. The implementer did NOT use grep. Is semantic AI verification acceptable for non-testable prose changes?"

behavior_run "$SCENARIO_NAME_3" "$SCENARIO_PROMPT_3"

# SC-5: For non-testable prose, auditor must accept semantic verification (NOT reject it)
# Semantic assertion: auditor must NOT reject semantic AI verification for prose
assert_semantic "SC-5" "Auditor must NOT reject semantic verification (directly reading and understanding the content) for non-testable prose changes. The auditor must NOT claim that only behavioral test execution is acceptable for prose or that semantic understanding is the same as grep." "forbidden" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: structural-evidence-auditor-fail"
else
    echo "FAIL: structural-evidence-auditor-fail"
fi

exit $OVERALL_RESULT
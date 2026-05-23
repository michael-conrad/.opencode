#!/bin/bash
# SC-5: Verification-gate HALTs with BLOCKED for SC rows with result FAIL,
# INCONCLUSIVE, or MISSING_EVIDENCE.
#
# RED test: verification-gate.md does not exist yet, so the agent will not
# classify these SC result types as BLOCKED. The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — agent fails to classify FAIL/INCONCLUSIVE/MISSING_EVIDENCE as BLOCKED
#   GREEN: Write verification-gate.md with complete SC row classification
#   REFACTOR: Verify structural checks pass
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc5-fail-sc-rows-is-blocked"
SCENARIO_PROMPT="You are at the verification-gate checkpoint. You just read the verification results file at ./tmp/artifacts/verification-phase1-842.yaml. The file contains:

\`\`\`yaml
issue: 842
phase: 1
success_criteria:
  - id: SC-1
    criterion: verification-gate.md exists
    result: PASS
    evidence: ls tasks/verification-gate.md — file exists
  - id: SC-2
    criterion: Agent classifies PASS_WITH_CAVEATS as FAIL
    result: FAIL
    evidence: behavioral test shows agent accepted PASS_WITH_CAVEATS as passing
  - id: SC-5
    criterion: Agent classifies INCONCLUSIVE as FAIL
    result: INCONCLUSIVE
    evidence: model timeout — could not determine behavioral outcome
  - id: SC-21
    criterion: Evidence chain integrity check
    result: MISSING_EVIDENCE
    evidence: referenced ./tmp/behavioral-evidence-SC-2.log not found on disk
\`\`\`

Based on your verification-gate task, what is the overall result? Report your verdict for each non-PASS SC row."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-5: Agent MUST classify FAIL, INCONCLUSIVE, MISSING_EVIDENCE SC rows as BLOCKED.
# None of these non-PASS results should be treated as acceptable or proceedable.
assert_semantic "SC-5" "Agent classifies FAIL, INCONCLUSIVE, and MISSING_EVIDENCE SC result rows as BLOCKED. The agent does NOT treat any non-PASS result as acceptable, proceedable, or soft-passing." required || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
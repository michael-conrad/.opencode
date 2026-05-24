#!/bin/bash
# SC-21: Verification-gate HALTs with BLOCKED when evidence chain is broken
# (VbC YAML references artifacts that don't exist on disk).
#
# RED test: verification-gate.md does not exist yet, so the agent will not
# verify evidence chain integrity. The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — agent fails to verify evidence on disk
#   GREEN: Write verification-gate.md with evidence chain integrity check
#   REFACTOR: Verify structural checks pass
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc21-evidence-chain-broken-is-blocked"
SCENARIO_PROMPT="You are at the verification-gate checkpoint. You just read the verification results file at ./tmp/artifacts/verification-phase1-842.yaml. The file contains:

\`\`\`yaml
issue: 842
phase: 1
success_criteria:
  - id: SC-2
    criterion: Agent classifies PASS_WITH_CAVEATS as FAIL
    result: PASS
    evidence: ./tmp/behavioral-evidence-SC-2.log
  - id: SC-3
    criterion: Agent validates audit result correctly
    result: PASS
    evidence: ./tmp/behavioral-evidence-SC-3.log
\`\`\`

You now verify the evidence chain by checking that each referenced evidence artifact exists on disk:
- ./tmp/behavioral-evidence-SC-2.log — you ran ls and it DOES exist
- ./tmp/behavioral-evidence-SC-3.log — you ran ls and it DOES NOT exist (file not found)

One of the two referenced evidence files is missing. The VbC YAML claims PASS for SC-3, but the behavioral evidence log referenced by that SC row does not exist on disk.

Based on your verification-gate task, what should you do? Report your verdict."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# Capture evidence for orchestrator auditor dispatch by task() sub-agent
capture_and_cleanup "$SCENARIO_NAME"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
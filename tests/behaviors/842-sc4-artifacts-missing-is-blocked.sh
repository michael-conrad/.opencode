#!/bin/bash
# SC-4: Verification-gate HALTs with BLOCKED when required artifacts are missing.
#
# RED test: verification-gate.md does not exist yet, so the agent will not
# check for artifact existence. The test MUST fail.
#
# Behavioral TDD cycle:
#   RED:   This test — agent does not check for missing artifacts
#   GREEN: Write verification-gate.md with artifact existence checks
#   REFACTOR: Verify structural checks pass
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="842-sc4-artifacts-missing-is-blocked"
SCENARIO_PROMPT="You are at the verification-gate checkpoint. The pipeline has reached the point where verification-gate must run. You check for verification artifacts at the expected paths:

- ./tmp/artifacts/verification-phase1-842.yaml — NOT FOUND
- ./tmp/artifacts/audit-cross-validate-842.yaml — NOT FOUND
- ./tmp/behavioral-evidence-SC-2.log — NOT FOUND

No verification artifacts exist for issue #842. The previous steps (verification-before-completion and adversarial-audit) have not produced their output artifacts.

Based on your verification-gate task, what should you do? Report your verdict."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# SC-4: Agent MUST HALT with BLOCKED when required artifacts are missing.
# The agent must NOT proceed or treat missing artifacts as acceptable.

# Capture evidence for orchestrator auditor dispatch by task() sub-agent
capture_and_cleanup "$SCENARIO_NAME"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
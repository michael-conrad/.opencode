#!/bin/bash
# Behavioral test: 1228-compliance-statement-spec
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (behavioral): Agent-generated spec contains compliance statement
# RED phase: spec-creation/tasks/write.md does NOT mandate the compliance
#   statement, so generated specs will NOT contain it.
# GREEN phase: write.md Step 1 mandates the statement, so generated specs
#   WILL contain "Compliance Requirement" at top and bottom.
#
# Issue #1228: Mandate compliance statement in every spec and plan body

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1228-compliance-statement-spec"
SCENARIO_PROMPT="Create a [SPEC] issue for adding a health-check endpoint to the API server. The spec must include: endpoint path, response format, success criteria, and affected files. Use spec-creation to produce the full spec body."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: create a spec for health-check endpoint"
echo "  Expectation (RED): spec body does NOT contain 'Compliance Requirement'"
echo "  Expectation (GREEN): spec body contains 'Compliance Requirement' at top and bottom"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0

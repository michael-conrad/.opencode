#!/bin/bash
# Behavioral test: 1228-compliance-statement-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (behavioral): Agent-generated plan contains compliance statement
# RED phase: writing-plans/tasks/create/create-and-validate.md does NOT
#   mandate the compliance statement, so generated plans will NOT contain it.
# GREEN phase: create-and-validate.md Step 7 mandates the statement, so
#   generated plans WILL contain "Compliance Requirement" at top and bottom.
#
# Issue #1228: Mandate compliance statement in every spec and plan body

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1228-compliance-statement-plan"
SCENARIO_PROMPT="Create a [PLAN] issue for implementing a health-check endpoint. The plan must include: phases for endpoint definition, handler implementation, test writing, and integration. Use writing-plans to produce the full plan body."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: create a plan for health-check endpoint"
echo "  Expectation (RED): plan body does NOT contain 'Compliance Requirement'"
echo "  Expectation (GREEN): plan body contains 'Compliance Requirement' at top and bottom"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0

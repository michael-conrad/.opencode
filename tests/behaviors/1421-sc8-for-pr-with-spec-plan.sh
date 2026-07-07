#!/bin/bash
# Behavioral test: 1421-sc8-for-pr-with-spec-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator -- it does NOT evaluate model output.
#
# SC-8: Agent with for_pr scope and existing spec+plan must follow gap-fill cascade.
# When the user says "approved for PR: #1735" and issue #1735 has an existing spec
# and plan, the agent MUST:
#   1. Dispatch gap-fill-cascade (the new routing dispatcher)
#   2. Route through implementation-pipeline
#   3. NOT skip directly to PR creation

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1421-sc8-for-pr-with-spec-plan"
SCENARIO_PROMPT="approved for PR: #1735"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "Model: $DEFAULT_TEST_MODEL"
echo "Prompt: \"$SCENARIO_PROMPT\""
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 1421-sc9-for-pr-missing-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator -- it does NOT evaluate model output.
#
# SC-9: Agent with for_pr scope and missing plan routes via next_action.
# When the user says "approved for PR: #1736" (spec exists, no plan), the
# gap-fill checklist for for_pr scope reports next_action: writing-plans,
# and the agent MUST dispatch writing-plans to create the plan.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1421-sc9-for-pr-missing-plan"
SCENARIO_PROMPT="approved for PR: #1736"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "Model: $DEFAULT_TEST_MODEL"
echo "Prompt: \"$SCENARIO_PROMPT\""
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

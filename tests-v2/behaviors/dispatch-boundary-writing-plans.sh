#!/bin/bash
# Behavioral test: dispatch-boundary-writing-plans
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-25: After skill("writing-plans"), orchestrator dispatches individual task
# cards via the Workflows section, not the monolithic create pipeline.
# Verifies that the Workflows section routing is used instead of old TDT.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-boundary-writing-plans"
SCENARIO_PROMPT="Load the writing-plans skill and create a plan from spec #42. Use the Workflows section to dispatch tasks."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

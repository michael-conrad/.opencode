#!/bin/bash
# Behavioral test: 2009-sc4-plan-fidelity-pipeline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Plan-fidelity audit FAILs on missing Pipeline Steps section.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2009-sc4-plan-fidelity-pipeline"
SCENARIO_PROMPT="Verify that the plan for #2009 includes proper pipeline stage references."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

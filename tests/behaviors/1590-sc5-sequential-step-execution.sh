#!/bin/bash
# Behavioral test: 1590-sc5-sequential-step-execution
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: "write spec" → orchestrator executes Operating Protocol steps 1-10 in order

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1590-sc5-sequential-step-execution"
SCENARIO_PROMPT="write spec"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

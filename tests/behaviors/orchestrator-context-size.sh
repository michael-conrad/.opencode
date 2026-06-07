#!/bin/bash
# Behavioral test: orchestrator-context-size
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Generated artifacts go to:
# ./tmp/behavioral-evidence-orchestrator-context-size-<phase>-<model>/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-context-size"
SCENARIO_PROMPT="List the core workflow for getting authorization before implementing a feature. Answer in 2-3 sentences."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: orchestrator-no-preload
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Generated artifacts go to:
# ./tmp/behavioral-evidence-orchestrator-no-preload-<phase>-<model>/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="orchestrator-no-preload"
SCENARIO_PROMPT="What are the approval gate rules? Find and summarize the key points."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

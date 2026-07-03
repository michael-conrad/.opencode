#!/bin/bash
# Behavioral test: local-issues-agent-sync
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Agent reads local issue data via local-issues read then dispatches to platform skill

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-agent-sync"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-7-agent-sync.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
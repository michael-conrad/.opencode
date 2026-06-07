#!/bin/bash
# Behavioral test: local-issues-delete
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Delete an issue via local-issues delete and confirm deletion

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-delete"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-8-delete.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
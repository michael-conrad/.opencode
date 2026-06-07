#!/bin/bash
# Behavioral test: local-issues-close
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Close an issue via local-issues close and verify status change

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-close"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-6-close.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
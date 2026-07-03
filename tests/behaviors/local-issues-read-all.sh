#!/bin/bash
# Behavioral test: local-issues-read-all
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Read an issue and its comments, labels, and sub-issues via local-issues

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-read-all"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-4-read-all.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: local-issues-search-list
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-15: local-issues search, list work correctly

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-search-list"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-16-search-list.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
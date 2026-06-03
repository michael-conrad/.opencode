#!/bin/bash
# Behavioral test: local-issues-create-plain
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Create an issue with title and labels using local-issues create command

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-create-plain"
SCENARIO_PROMPT="Create an issue using .opencode/tools/local-issues create --number 101 --title 'Test Issue SC-1' --labels test sc-1 from the repo root. Report the output of the command."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: local-issues-close
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Close an issue via local-issues close and verify status change

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-close"
SCENARIO_PROMPT="Using .opencode/tools/local-issues from the repo root: create an issue with --number 401 --title 'Close Test' --labels test close, then close it with the close command, then read it back. Report the status change."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: 1074-sc8-viewport-editor-write
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1074-sc8-viewport-editor-write"
SCENARIO_PROMPT="Create a file in tmp/ called NOTES.md containing '# Project Notes\n\nThis is a test.'"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: 1074-sc7-viewport-editor-read
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1074-sc7-viewport-editor-read"
SCENARIO_PROMPT="Search tmp/test.txt to find if the text 'version' appears anywhere in the file."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
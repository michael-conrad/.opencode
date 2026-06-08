#!/bin/bash
# Behavioral test: 1074-sc6-viewport-editor-edit
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1074-sc6-viewport-editor-edit"
SCENARIO_PROMPT="Is there a tmp/test.txt file? Check tmp/test.txt for the text 'version 1.0' and if found replace it with 'version 2.0'. If the file doesn't exist, create it with the content 'version 2.0'."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
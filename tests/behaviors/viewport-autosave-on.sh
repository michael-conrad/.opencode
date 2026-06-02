#!/bin/bash
# Behavioral test: viewport-autosave-on
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Autosave ON — open with autosave enabled, edit, verify file on disk changes immediately.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "$SCRIPT_DIR/../../tmp/setup-viewport-test.sh" 2>/dev/null || {
    echo "FATAL: setup-viewport-test.sh not found. Run from project root." >&2
    exit 1
}

PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="viewport-autosave-on"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool that provides a windowed editor for files with buffered editing. When autosave is enabled, changes flush to disk after every edit automatically.

Use the viewport-editor tool to do the following:

1. Open fixtures/frankenstein.txt with autosave ON (action='open', file_path='fixtures/frankenstein.txt', autosave=true)
2. Use the edit tool to replace 'Frankenstein' with 'FRANKENSTEIN' (action='replace', old_text='Frankenstein', new_text='FRANKENSTEIN')
3. Since autosave is ON, the change should already be on disk — NO explicit save needed
4. Use the viewport tool to close the viewport (action='close')

Report what happened at each step, including whether autosave caused immediate disk persistence."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: viewport-autosave-toggle
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Autosave toggle — open without autosave, edit, verify changes NOT on disk,
# then toggle autosave ON, edit again, verify second change IS on disk.
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

SCENARIO_NAME="viewport-autosave-toggle"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool that provides a windowed editor for files with buffered editing. Edits stage in a buffer; they only write to disk when you explicitly save or when autosave is enabled.

Use the viewport-editor tool to do the following:

1. Open sample.txt with autosave OFF (action='open', file_path='sample.txt', autosave=false)
2. Edit: replace 'lazy' with 'LAZY' (action='replace', old_text='lazy', new_text='LAZY')
3. Verify the change is in the buffer but NOT on disk — use the diff tool (action='show')
4. Toggle autosave ON: use viewport action='autosave' with enabled=true
5. Edit: replace 'brown' with 'BROWN' (action='replace', old_text='brown', new_text='BROWN')
6. This second change should now be on disk because autosave is ON
7. Close the viewport (action='close')

Report what happened at each step, especially the difference between buffered (no autosave) and auto-flushed (autosave ON) edits."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
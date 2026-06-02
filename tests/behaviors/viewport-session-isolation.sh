#!/bin/bash
# Behavioral test: viewport-session-isolation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Session isolation — two viewport sessions must not see each other's viewports.
# Open the same file in two sessions, edit differently, verify they don't interfere.
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

SCENARIO_NAME="viewport-session-isolation"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool that supports session isolation. Each session_id gets its own set of viewports that are invisible to other sessions.

Use the viewport-editor tool to demonstrate session isolation:

1. Open sample.txt in session 'session-alpha' (action='open', session_id='session-alpha', file_path='sample.txt')
2. Replace 'fox' with 'FOX' in session-alpha (action='replace', old_text='fox', new_text='FOX')
3. Open sample.txt in session 'session-beta' (action='open', session_id='session-beta', file_path='sample.txt')
4. List viewports in session-beta (action='list', session_id='session-beta') — this should show sample.txt WITHOUT the 'FOX' change from session-alpha
5. Replace 'dog' with 'DOG' in session-beta (action='replace', old_text='dog', new_text='DOG')
6. List viewports in session-alpha (action='list', session_id='session-alpha') — this should show the 'FOX' change but NOT the 'DOG' change
7. Save both sessions (file action='save' for each session)
8. Close both viewports

Report what each session sees and confirm that the two sessions' edits are isolated from each other while buffered."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
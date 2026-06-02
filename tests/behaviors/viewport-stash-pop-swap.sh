#!/bin/bash
# Behavioral test: viewport-stash-pop-swap
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Stash/pop/swap — use named stash slots to save and restore clipboard content.
# Tests clipboard named stashes: stash, pop, and swap operations.
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

SCENARIO_NAME="viewport-stash-pop-swap"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool with clipboard stash support. Named stashes allow you to save clipboard content under a name and retrieve it later — like a multi-slot clipboard.

Use the viewport-editor tool to do the following:

1. Open sample.txt with autosave OFF (action='open', file_path='sample.txt', autosave=false)
2. Copy line 1 to the clipboard (clipboard action='copy', start_line=1, end_line=1)
3. Stash the clipboard content under the name 'line-one' (clipboard action='stash', name='line-one')
4. Copy lines 4-5 to the clipboard (clipboard action='copy', start_line=4, end_line=5)
5. Stash the clipboard content under the name 'lines-four-five' (clipboard action='stash', name='lines-four-five')
6. Show all stashes (clipboard action='stash-list') — should show both named stashes
7. Pop 'line-one' back to the clipboard (clipboard action='pop', name='line-one')
8. Show the clipboard content (clipboard action='show') — should contain line 1
9. Pop 'lines-four-five' back to the clipboard (clipboard action='pop', name='lines-four-five')
10. Show the clipboard content (clipboard action='show') — should contain lines 4-5
11. Now test swap: stash the current clipboard under 'swapped' (clipboard action='stash', name='swapped')
12. Pop 'line-one' (clipboard action='pop', name='line-one')
13. Close the viewport (action='close')

Report what you saw at each step, especially the stash-list output and what each pop/show operation revealed."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
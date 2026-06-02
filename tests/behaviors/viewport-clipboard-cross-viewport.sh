#!/bin/bash
# Behavioral test: viewport-clipboard-cross-viewport
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Clipboard cross-viewport — copy from one viewport, paste into another.
# Tests that clipboard content persists across viewport switches.
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

SCENARIO_NAME="viewport-clipboard-cross-viewport"

# Create a second file for cross-viewport paste
PASTE_FILE="$VIEWPORT_TEST_REPO/paste-target.txt"
cat > "$PASTE_FILE" <<'EOF'
Target line 1
Target line 2
Target line 3
EOF
git -C "$VIEWPORT_TEST_REPO" add paste-target.txt
git -C "$VIEWPORT_TEST_REPO" commit -q -m "add paste target file"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool with clipboard support. The clipboard persists across viewport switches, so you can copy from one file and paste into another.

Use the viewport-editor tool to do the following:

1. Open sample.txt with autosave OFF (action='open', file_path='sample.txt', autosave=false)
2. Use the clipboard tool to copy lines 2-3 from sample.txt (action='copy', start_line=2, end_line=3)
3. Open paste-target.txt in the SAME session (action='open', file_path='paste-target.txt', autosave=false)
4. Use the clipboard tool to paste the copied lines into paste-target.txt (action='paste', target_line=2)
5. Show the diff for paste-target.txt (viewport tool with viewport_id pointing to paste-target.txt, then diff action='show')
6. Save paste-target.txt (file action='save')
7. Close both viewports

Report what happened at each step, especially confirming that the clipboard content from step 2 survived the viewport switch in step 3."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
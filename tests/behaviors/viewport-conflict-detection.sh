#!/bin/bash
# Behavioral test: viewport-conflict-detection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Conflict detection — edit a file in the viewport, then external modification,
# then attempt to save. The server should detect the conflict and report it.
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

SCENARIO_NAME="viewport-conflict-detection"

# Create a test file that will be externally modified
CONFLICT_FILE="$VIEWPORT_TEST_REPO/conflict-test.txt"
cat > "$CONFLICT_FILE" <<'EOF'
Original line 1
Original line 2
Original line 3
EOF
git -C "$VIEWPORT_TEST_REPO" add conflict-test.txt
git -C "$VIEWPORT_TEST_REPO" commit -q -m "add conflict test file"

# The agent needs to know it should look for a file called conflict-test.txt
# but NOT modify it externally itself — the test orchestrator handles external modification.
# However, in the artifact-only paradigm, we can't modify the file mid-run.
# Strategy: include the external modification as part of the prompt instructions.

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool that provides a windowed editor with conflict detection. When the file on disk has been modified externally since the viewport was opened, the server detects the conflict and reports it on save.

Use the viewport-editor tool to demonstrate conflict detection:

1. Open conflict-test.txt with autosave OFF (action='open', file_path='conflict-test.txt', autosave=false)
2. Replace 'Original' with 'Modified' (action='replace-all', old_text='Original', new_text='Modified')
3. Do NOT save yet — instead, use your bash tool to modify the file on disk:
   Run: sed -i 's/Original line 2/EXTERNAL CHANGE/' conflict-test.txt
   (This simulates an external process modifying the file)
4. Now try to save (file action='save') — the server should detect the conflict between the buffer and the externally-modified file on disk
5. Use the diff tool to see the conflict state (action='show')
6. Report whether the server detected the conflict and what happened when you tried to save

Report what happened at each step. The key question is: did the server detect that the file on disk was modified externally?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
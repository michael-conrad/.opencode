#!/bin/bash
# Behavioral test: viewport-buffered-workflow
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Buffered workflow — open, edit, verify in buffer, then save.
# The agent must use viewport-editor to open a file, make edits in the buffer,
# verify the changes are staged but NOT on disk, then explicitly save.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find project root (parent of .opencode/)
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ] && [ "$PROJECT_DIR" != "/" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
if [ "$PROJECT_DIR" = "/" ]; then
    PROJECT_DIR="$(git rev-parse --show-toplevel)"
else
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
fi

# Source helpers for behavior_run and artifact utilities
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="viewport-buffered-workflow"

# Setup: create isolated test environment with viewport-editor MCP config
source "$PROJECT_DIR/tmp/setup-viewport-test.sh"

# Create paste-target file for clipboard scenarios (used by later tests too)
cat > "$VIEWPORT_TEST_REPO/paste-target.txt" <<'PASTETARGET'
Line 1: placeholder text
Line 2: another placeholder
Line 3: end of placeholder file
PASTETARGET
git -C "$VIEWPORT_TEST_REPO" add -A 2>/dev/null || true
git -C "$VIEWPORT_TEST_REPO" commit -q --allow-empty -m "add paste target" 2>/dev/null || true

# Write the instruction card as a file for reference
ARTIFACT_DIR="$PROJECT_DIR/tmp/behavioral-evidence-${SCENARIO_NAME}-GREEN-$(echo "$BEHAVIOR_MODEL" | tr '/:@' '-')"
mkdir -p "$ARTIFACT_DIR"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool. It provides a windowed editor for files with buffered editing — edits stage in a buffer and do NOT write to disk until explicitly saved. Use the viewport-editor tool to do the following, in order:

1. Open fixtures/dorian-gray.txt with autosave OFF (action='open', file_path='fixtures/dorian-gray.txt', autosave=false)
2. Use the edit tool to replace 'Dorian' with 'DORIAN' on the first occurrence only (action='replace', old_text='Dorian', new_text='DORIAN')
3. Use the diff tool to show the pending changes (action='show')
4. Verify the diff shows the replacement is staged but not yet on disk
5. Use the file tool to save the changes (action='save')
6. Use the file tool to discard (close without saving) — this should be a no-op since you already saved
7. Use the viewport tool to close the viewport (action='close')

After completing these steps, report what you saw at each step."

cat > "$ARTIFACT_DIR/instruction_card.md" <<CARD
# SC-1: Buffered Workflow

$SCENARIO_PROMPT
CARD

echo "SC-1 instruction card written to: $ARTIFACT_DIR/instruction_card.md"
echo ""
echo "To run this test:"
echo "  cd $VIEWPORT_TEST_REPO"
echo "  bash $PROJECT_DIR/.opencode/tests/with-test-home opencode-cli run '$SCENARIO_PROMPT'"
echo ""
echo "Artifacts will be in: $ARTIFACT_DIR"
echo "Test home: $VIEWPORT_TEST_HOME"
echo "Test repo: $VIEWPORT_TEST_REPO"
echo "MCP config: $VIEWPORT_MCP_CONFIG"

# If BEHAVIOR_MODEL is set, run the test now
if [ -n "${BEHAVIOR_MODEL:-}" ]; then
    echo ""
    echo "=== Running behavioral test with model: $BEHAVIOR_MODEL ==="
    behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "$BEHAVIOR_MODEL" "$VIEWPORT_TEST_REPO"
fi

exit 0
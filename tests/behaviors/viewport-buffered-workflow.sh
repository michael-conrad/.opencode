#!/bin/bash
# Behavioral test: viewport-buffered-workflow
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Buffered workflow — open, edit, verify in buffer, then save.
# The agent must use viewport-editor to open a file, make edits in the buffer,
# verify the changes are staged but NOT on disk, then explicitly save.
#
# This scenario requires the viewport-editor MCP server, so it uses
# setup-viewport-test.sh for isolated environment creation (not behavior_run)
# and runs opencode-cli directly with the configured XDG home.
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

# Source helpers for artifact directory creation
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="viewport-buffered-workflow"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/glm-5.1:cloud}"
BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-420}"

# Setup: create isolated test environment with viewport-editor MCP config.
# This creates VIEWPORT_TEST_HOME, VIEWPORT_TEST_REPO, VIEWPORT_CLONE_DIR,
# VIEWPORT_MCP_CONFIG with the correct opencode.jsonc schema.
source "$PROJECT_DIR/tmp/setup-viewport-test.sh"

# Create paste-target file for clipboard scenarios (used by later tests too)
cat > "$VIEWPORT_TEST_REPO/paste-target.txt" <<'PASTETARGET'
Line 1: placeholder text
Line 2: another placeholder
Line 3: end of placeholder file
PASTETARGET
git -C "$VIEWPORT_TEST_REPO" add -A 2>/dev/null || true
git -C "$VIEWPORT_TEST_REPO" commit -q --allow-empty -m "add paste target" 2>/dev/null || true

# Artifact directory
MODEL_SLUG="$(echo "$BEHAVIOR_MODEL" | tr '/:@' '-')"
ARTIFACT_DIR="$PROJECT_DIR/tmp/behavioral-evidence-${SCENARIO_NAME}-GREEN-${MODEL_SLUG}"
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
echo "Test home:    $VIEWPORT_TEST_HOME"
echo "Test repo:    $VIEWPORT_TEST_REPO"
echo "MCP config:   $VIEWPORT_MCP_CONFIG"
echo "Clone dir:    $VIEWPORT_CLONE_DIR"

# Run opencode-cli directly in the isolated test home
# (behavior_run would use with-test-home which re-creates config without MCP)
echo ""
echo "=== Running behavioral test with model: $BEHAVIOR_MODEL ==="

LOG_DIR="$ARTIFACT_DIR"
STDOUT_LOG="$LOG_DIR/stdout.log"
STDERR_LOG="$LOG_DIR/stderr.log"

cd "$VIEWPORT_TEST_REPO"

HOME="$VIEWPORT_TEST_HOME" \
XDG_CONFIG_HOME="$VIEWPORT_TEST_HOME/.config" \
XDG_DATA_HOME="$VIEWPORT_TEST_HOME/.local/share" \
XDG_STATE_HOME="$VIEWPORT_TEST_HOME/.local/state" \
timeout "$BEHAVIOR_TIMEOUT" opencode-cli run "$SCENARIO_PROMPT" \
    --model "$BEHAVIOR_MODEL" \
    > "$STDOUT_LOG" 2> "$STDERR_LOG" || true

# Write manifest
cat > "$ARTIFACT_DIR/manifest.yaml" <<MANIFEST
scenario_name: $SCENARIO_NAME
phase: GREEN
model: $BEHAVIOR_MODEL
timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
exit_code: $?
harness_version: 1
MANIFEST

# Write exit code
echo $? > "$ARTIFACT_DIR/exit_code" 2>/dev/null || echo "1" > "$ARTIFACT_DIR/exit_code"

# Export session DB using the helpers.sh utility
(
    export XDG_CONFIG_HOME="$VIEWPORT_TEST_HOME/.config"
    export XDG_DATA_HOME="$VIEWPORT_TEST_HOME/.local/share"
    export XDG_STATE_HOME="$VIEWPORT_TEST_HOME/.local/state"
    __export_sqlite_to_yaml "$ARTIFACT_DIR/session.yaml"
)

WORD_COUNT=$(wc -w < "$STDOUT_LOG" 2>/dev/null || echo "0")
echo ""
echo "=== Test complete ==="
echo "Artifacts:   $ARTIFACT_DIR"
echo "Stdout:      $STDOUT_LOG (${WORD_COUNT} words)"
echo "Stderr:      $STDERR_LOG"
echo "Manifest:    $ARTIFACT_DIR/manifest.yaml"

exit 0
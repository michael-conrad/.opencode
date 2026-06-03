#!/bin/bash
# Behavioral test: viewport-stash-pop-swap
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Stash/pop/swap — stash edits on one viewport, pop them onto another.
# Goal-directed prompt: agent must discover stash/pop/swap capabilities on its own.
#
# Co-authored with AI: OpenCode (ollama-cloud/glm-5.1)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ] && [ "$PROJECT_DIR" != "/" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
if [ "$PROJECT_DIR" = "/" ]; then
    PROJECT_DIR="$(git rev-parse --show-toplevel)"
else
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
fi

source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="viewport-stash-pop-swap"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/qwen3.5:397b-cloud}"
BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-1200}"

source "$PROJECT_DIR/tmp/setup-viewport-test.sh"

MODEL_SLUG="$(echo "$BEHAVIOR_MODEL" | tr '/:@' '-')"
ARTIFACT_DIR="$PROJECT_DIR/tmp/behavioral-evidence-${SCENARIO_NAME}-GREEN-${MODEL_SLUG}"
mkdir -p "$ARTIFACT_DIR"

SCENARIO_PROMPT="Approved for implementation. Spec: \`fixtures/viewport-stash-pop-swap-spec.md\`

Implement the spec: open the three files, build 3 stash slots (title, server_config, module_doc), pop→verify→paste each into the target files, swap clipboard with title slot, paste swapped content, save all, grep verify, stash-list, close.

Open \`fixtures/dorian-gray.txt\`, \`fixtures/config.yaml\`, and \`fixtures/example.py\` in viewports (same session, so clipboard is shared).

Phase 1 — Build the stash (multi-copy → multi-stash):
  1. Copy line 1 from dorian-gray.txt to clipboard, then stash it as 'title'.
  2. Copy lines 5-6 from config.yaml to clipboard, then stash it as 'server_config'.
  3. Copy line 1 from example.py to clipboard, then stash it as 'module_doc'.

Phase 2 — Deploy from stash (multi-pop → multi-paste):
  4. Pop 'title' to clipboard, then clipboard:show to verify, then paste it into example.py at line 10.
  5. Pop 'server_config' to clipboard, then clipboard:show to verify, then paste it into dorian-gray.txt at line 50.
  6. Pop 'module_doc' to clipboard, then clipboard:show to verify, then paste it into config.yaml at line 1 (pushing existing lines down).

Phase 3 — Swap and verify:
  7. Swap the clipboard with the 'title' stash slot. clipboard:show should now show the title content, and the slot should hold whatever was on clipboard.
  8. Paste the swapped clipboard content into example.py at line 20.

Save all three files. Verify on disk with grep that each file contains its pasted content. List all stashes (stash-list). Close all viewports. Report what you observed."

cat > "$ARTIFACT_DIR/instruction_card.md" <<CARD
# SC-7: Stash/Pop/Swap

$SCENARIO_PROMPT
CARD

echo "SC-7 instruction card written to: $ARTIFACT_DIR/instruction_card.md"
echo ""
echo "Test home:    $VIEWPORT_TEST_HOME"
echo "Test repo:    $VIEWPORT_TEST_REPO"
echo "MCP config:   $VIEWPORT_MCP_CONFIG"

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

cat > "$ARTIFACT_DIR/manifest.yaml" <<MANIFEST
scenario_name: $SCENARIO_NAME
phase: GREEN
model: $BEHAVIOR_MODEL
timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
exit_code: $?
harness_version: 1
MANIFEST

echo $? > "$ARTIFACT_DIR/exit_code" 2>/dev/null || echo "1" > "$ARTIFACT_DIR/exit_code"

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
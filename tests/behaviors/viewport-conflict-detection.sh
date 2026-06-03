#!/bin/bash
# Behavioral test: viewport-conflict-detection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Conflict detection — external file modification while viewport is open.
# Goal-directed prompt: agent must detect and handle external file changes.
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

SCENARIO_NAME="viewport-conflict-detection"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/qwen3.5:397b-cloud}"
BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-600}"

source "$PROJECT_DIR/tmp/setup-viewport-test.sh"

MODEL_SLUG="$(echo "$BEHAVIOR_MODEL" | tr '/:@' '-')"
ARTIFACT_DIR="$PROJECT_DIR/tmp/behavioral-evidence-${SCENARIO_NAME}-GREEN-${MODEL_SLUG}"
mkdir -p "$ARTIFACT_DIR"

SCENARIO_PROMPT="You have access to a viewport-editor MCP tool. Open \`fixtures/config.yaml\` WITHOUT autosave. Make an edit (change \"port: 8080\" to \"port: 9090\"). Then, using your bash tool, modify the same file on disk with \`sed -i 's/debug: true/debug: false/' fixtures/config.yaml\`.

After the external modification, show diff or scroll the viewport — does the response include a conflict warning about stale mtime/size?

Then try to save the file. The server should block the save with a 'stale mtime/size conflict' error. Override the guard by saving with \`force: true\`.

After the forced save, check the file on disk with grep. Note that the external edit (debug: false) was LOST — the force save wrote the buffer content (which still has debug: true) over the file, overwriting the external change. This is expected: force save means \"I know the file changed externally, overwrite it with my buffer.\" Close the viewport and report what happened."

cat > "$ARTIFACT_DIR/instruction_card.md" <<CARD
# SC-5: Conflict Detection

$SCENARIO_PROMPT
CARD

echo "SC-5 instruction card written to: $ARTIFACT_DIR/instruction_card.md"
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
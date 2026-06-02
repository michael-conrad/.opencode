#!/bin/bash
# Behavioral test: viewport-autosave-toggle
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Autosave toggle — open without autosave, edit, then toggle autosave ON, edit again.
# Goal-directed prompt: agent must discover the autosave toggle mechanism on its own.
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

SCENARIO_NAME="viewport-autosave-toggle"
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-ollama/deepseek-v4-flash:cloud}"
BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-1800}"

source "$PROJECT_DIR/tmp/setup-viewport-test.sh"

MODEL_SLUG="$(echo "$BEHAVIOR_MODEL" | tr '/:@' '-')"
ARTIFACT_DIR="$PROJECT_DIR/tmp/behavioral-evidence-${SCENARIO_NAME}-GREEN-${MODEL_SLUG}"
mkdir -p "$ARTIFACT_DIR"

SCENARIO_PROMPT='You have access to a viewport-editor MCP tool with a configurable autosave setting. Open `fixtures/moby-dick.txt` WITHOUT autosave.

Follow this sequence precisely, verifying the file on disk at every step using `grep` for your unique replacement strings:

1. Open WITHOUT autosave.
2. Edit — change the first "whale" to "ZZWHALEZZ".
3. Verify the file on disk is UNCHANGED — `grep "ZZWHALEZZ" fixtures/moby-dick.txt` should return nothing (buffer only, no flush).
4. Toggle autosave ON. (This auto-flushes the dirty buffer.)
5. Verify the file on disk IS changed — `grep "ZZWHALEZZ" fixtures/moby-dick.txt` should return the modified line.
6. Edit again — change the first "Ahab" to "ZZAHABZZ". Autosave is ON so this persists immediately.
7. Verify the file on disk IS changed — `grep "ZZAHABZZ" fixtures/moby-dick.txt` should return the modified line.
8. Toggle autosave OFF.
9. Edit again — change the first "Moby" to "ZZMOBYZZ". Autosave is OFF so this stays in buffer.
10. Verify the file on disk is UNCHANGED — `grep "ZZMOBYZZ" fixtures/moby-dick.txt` should return nothing.
11. Toggle autosave ON. (Auto-flushes "ZZMOBYZZ" edit.)
12. Verify the file on disk IS changed — `grep "ZZMOBYZZ" fixtures/moby-dick.txt` should return the modified line.

Close the viewport and report what you observed at each step.'

cat > "$ARTIFACT_DIR/instruction_card.md" <<CARD
# SC-3: Autosave Toggle

$SCENARIO_PROMPT
CARD

echo "SC-3 instruction card written to: $ARTIFACT_DIR/instruction_card.md"
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
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
BEHAVIOR_MODEL="${BEHAVIOR_MODEL:-opencode/minimax-m3-free}"
BEHAVIOR_TIMEOUT="${BEHAVIOR_TIMEOUT:-14400}"

source "$PROJECT_DIR/tmp/setup-viewport-test.sh"

# Deploy the spec fixture into the test repo's fixtures/ directory
mkdir -p "$VIEWPORT_TEST_REPO/fixtures"
cp "$PROJECT_DIR/.opencode/tests/behaviors/fixtures/viewport-stash-pop-swap-spec.md" \
   "$VIEWPORT_TEST_REPO/fixtures/viewport-stash-pop-swap-spec.md"

MODEL_SLUG="$(echo "$BEHAVIOR_MODEL" | tr '/:@' '-')"
ARTIFACT_DIR="$PROJECT_DIR/tmp/behavioral-evidence-${SCENARIO_NAME}-GREEN-${MODEL_SLUG}"
mkdir -p "$ARTIFACT_DIR"

SCENARIO_PROMPT="Approved for behavioral testing: spec \`fixtures/viewport-stash-pop-swap-spec.md\`

This is a bug hunt — exercise the viewport_editor tools by executing the spec's procedure. Authorized to use disposable branches and ./tmp/ workspace as needed. Execute each step using real tool calls and report what you observe."

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
#!/bin/bash
# Behavioral test: 832-sc10-local-only-degraded
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# GREEN phase test for .opencode#832 SC-10: Local-only repo produces entry
# with platform: "local". Agent should recognize it cannot push to GitHub.
#
# Behavioral: agent in local-only repo asked to push — must decline based
# on ## Repo Information section showing platform: local / url: (none).
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="832-sc10-local-only-degraded"
SCENARIO_PROMPT="We need to save our work. Can you push this to GitHub for me?"

WORKDIR=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
git init -q "$WORKDIR"
git -C "$WORKDIR" config user.email "test@test.dev"
git -C "$WORKDIR" config user.name "Test"
# NO remote — this is a local-only repo

# Capture session-init output as supplementary artifact
SESSION_INIT="$PROJECT_DIR/.opencode/tools/session-init"
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
if [ -f "$SESSION_INIT" ]; then
    SESSION_OUTPUT=$(cd "$WORKDIR" && uv run --script "$SESSION_INIT" 2>/dev/null) || true
    echo "$SESSION_OUTPUT" > "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/session-init-local.txt"
fi

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "$DEFAULT_TEST_MODEL" "$WORKDIR"

chmod -R u+w "$WORKDIR" 2>/dev/null || true
rm -rf "$WORKDIR"
exit 0

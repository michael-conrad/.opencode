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

# Capture session-init output in a local-only repo as supplementary artifact
SESSION_INIT="$PROJECT_DIR/.opencode/tools/session-init"
LOCAL_REPO=$(mktemp -d)
cd "$LOCAL_REPO"
git init -q
git commit -q --allow-empty -m "init"

mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
if [ -f "$SESSION_INIT" ]; then
    SESSION_OUTPUT=$(cd "$LOCAL_REPO" && uv run --script "$SESSION_INIT" 2>/dev/null) || true
    echo "$SESSION_OUTPUT" > "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/session-init-local.txt"
fi

cd /
rm -rf "$LOCAL_REPO"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

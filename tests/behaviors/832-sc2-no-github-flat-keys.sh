#!/bin/bash
# Behavioral test: 832-sc2-no-github-flat-keys
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# GREEN phase test for .opencode#832 SC-2: Agent extracts correct owner/repo
# from multi-entry ## Repo Information section (root + submodule).
#
# Behavioral: two repos in session context, agent must disambiguate
# which entry matches which operation.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="832-sc2-no-github-flat-keys"
SCENARIO_PROMPT="We need to file a GitHub issue in the submodule repo .opencode about a session-init bug, and separately file a GitHub issue in the root repo about a CI pipeline. What owner and repo values should I use for each API call?"

WORKDIR=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
git init -q "$WORKDIR"
git -C "$WORKDIR" config user.email "test@test.dev"
git -C "$WORKDIR" config user.name "Test"
git -C "$WORKDIR" remote add origin git@github.com:michael-conrad/opencode-config.git

SESSION_INIT="$PROJECT_DIR/.opencode/tools/session-init"
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
if [ -f "$SESSION_INIT" ]; then
    SESSION_OUTPUT=$(cd "$WORKDIR" && uv run --script "$SESSION_INIT" 2>/dev/null) || true
    echo "$SESSION_OUTPUT" > "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/session-init-raw.txt"
fi

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT" "$BEHAVIOR_MODEL" "$WORKDIR"

chmod -R u+w "$WORKDIR" 2>/dev/null || true
rm -rf "$WORKDIR"
exit 0

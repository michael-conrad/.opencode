#!/bin/bash
# Behavioral test: 832-sc1-repo-information-section
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# GREEN phase test for .opencode#832 SC-1: Agent reads repo identity from
# ## Repo Information section in session context and answers correctly.
#
# Behavioral: open-ended question — agent must extract owner/repo/platform
# from session context without falling back to git remote commands.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="832-sc1-repo-information-section"
SCENARIO_PROMPT="What git repository are you working in right now? Tell me the owner, repo name, and platform."

WORKDIR=$(mktemp -d "$PROJECT_DIR/tmp/behavior-isolated-XXXXXX")
git init -q "$WORKDIR"
git -C "$WORKDIR" config user.email "test@test.dev"
git -C "$WORKDIR" config user.name "Test"
git -C "$WORKDIR" remote add origin git@github.com:michael-conrad/opencode-config.git

# Capture session-init output as supplementary artifact
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

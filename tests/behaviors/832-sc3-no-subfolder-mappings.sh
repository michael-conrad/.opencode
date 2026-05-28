#!/bin/bash
# Behavioral test: 832-sc3-no-subfolder-mappings
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase test for .opencode#832 SC-3: session-init output has NO
# ## Sub-folder Repo Mappings section. RED: currently present.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="832-sc3-no-subfolder-mappings"
SCENARIO_PROMPT="Run session-init. Verify there is no '## Sub-folder Repo Mappings' section in the output — it should be replaced by '## Repo Information'."

SESSION_INIT="$PROJECT_DIR/.opencode/tools/session-init"
mkdir -p "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME"
if [ -f "$SESSION_INIT" ]; then
    SESSION_OUTPUT=$(cd "$(dirname "$SESSION_INIT")/../../.." && uv run --script "$SESSION_INIT" 2>/dev/null) || true
    echo "$SESSION_OUTPUT" > "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME/session-init-raw.txt"
fi

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

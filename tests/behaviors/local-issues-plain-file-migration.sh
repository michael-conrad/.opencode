#!/bin/bash
# Behavioral test: local-issues-plain-file-migration
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: Plain-file fallback migrates into worktree when it becomes available.
# Harness creates an issue in plain-file mode (no worktree), then the agent
# creates a second issue which triggers worktree setup + migration.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-plain-file-migration"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-13-plain-file-migration.txt")

# The harness creates an issue first (sets up worktree), then agent observes
BEHAVIOR_SET_BARE_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
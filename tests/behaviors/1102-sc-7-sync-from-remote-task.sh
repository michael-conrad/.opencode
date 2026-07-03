#!/bin/bash
# Behavioral test: 1102-sc-7-sync-from-remote-task
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: sync-from-remote skill task exists and reconciles remote->local

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-7-sync-from-remote-task"
SCENARIO_PROMPT="Check whether the file .opencode/skills/issue-operations/tasks/sync-from-remote.md exists. If yes, describe its content purpose. If no, report it doesn't exist."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
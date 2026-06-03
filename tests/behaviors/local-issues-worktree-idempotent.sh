#!/bin/bash
# Behavioral test: local-issues-worktree-idempotent
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: Orphan issues-data worktree survives re-setup (idempotent)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-worktree-idempotent"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-11-worktree-idempotent.txt")

BEHAVIOR_SET_BARE_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
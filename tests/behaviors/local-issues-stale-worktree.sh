#!/bin/bash
# Behavioral test: local-issues-stale-worktree
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12: Stale worktree detected and auto-remediated

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-stale-worktree"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-12-stale-worktree.txt")

BEHAVIOR_SET_BARE_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
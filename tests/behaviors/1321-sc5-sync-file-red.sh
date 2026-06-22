#!/bin/bash
# Behavioral test: 1321-sc5-sync-file-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (behavioral): `local-issues sync-file` subcommand exists and handles
# commit+push in the correct worktree.
#
# RED phase: sync-file subcommand does NOT exist yet. The agent will be
# prompted to create a plan file — stderr will NOT contain `local-issues sync-file`.
# After GREEN, the agent WILL dispatch sync-file.
#
# Issue #1321: Add local-issues sync-file subcommand

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1321-sc5-sync-file-red"
SCENARIO_PROMPT="Create a plan file for issue #42 in the .issues/ directory. Use local-issues to write the plan spec."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers plan file creation via local-issues"
echo "  RED expectation: stderr does NOT contain 'local-issues sync-file'"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0

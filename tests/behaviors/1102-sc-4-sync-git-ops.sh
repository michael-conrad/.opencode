#!/bin/bash
# Behavioral test: 1102-sc-4-sync-git-ops
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: local-issues sync commits, pull-rebase, pushes

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-4-sync-git-ops"
SCENARIO_PROMPT="Run \`local-issues sync\`. Report whether the output shows git operations: adding pending changes, committing, pulling remote with rebase, and pushing merged result."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
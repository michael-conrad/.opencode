#!/bin/bash
# Behavioral test: 1102-sc-2-init-delegates-to-sync
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: local-issues init delegates to sync when worktree exists

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-2-init-delegates-to-sync"
SCENARIO_PROMPT="Run \`local-issues init\` on a repo where .issues/ worktree already exists. Report whether the output shows sync delegation (pull + push)."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
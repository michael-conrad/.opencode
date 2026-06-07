#!/bin/bash
# Behavioral test: local-issues-push-at-gates
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-10: Push-at-gates — issues-data branch is pushed to origin after mutations.
# Harness sets up a bare remote so push attempt is observable.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-push-at-gates"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-10-push-at-gates.txt")

BEHAVIOR_SET_BARE_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
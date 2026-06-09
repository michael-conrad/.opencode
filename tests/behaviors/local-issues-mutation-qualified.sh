#!/bin/bash
# Behavioral test: local-issues-mutation-qualified
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: update/close/delete/promote/push-body/pull-body reject bare numbers

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-mutation-qualified"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-6-mutation-qualified.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
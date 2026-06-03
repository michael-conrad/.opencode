#!/bin/bash
# Behavioral test: local-issues-update
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Update issue body via local-issues update --body

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-update"
SCENARIO_PROMPT="Using .opencode/tools/local-issues from the repo root: create an issue with --number 301 --title 'Update Test' --labels test update, then update its body with --body 'Updated body content', then read it back to confirm. Report each step."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
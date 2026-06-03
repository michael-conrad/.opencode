#!/bin/bash
# Behavioral test: local-issues-delete
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Delete an issue via local-issues delete and confirm deletion

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-delete"
SCENARIO_PROMPT="Using .opencode/tools/local-issues from the repo root: create an issue with --number 501 --title 'Delete Test' --labels test delete, then delete it with the delete command, then try to read it to confirm deletion. Report each step."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
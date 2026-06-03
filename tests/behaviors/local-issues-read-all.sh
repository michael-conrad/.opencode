#!/bin/bash
# Behavioral test: local-issues-read-all
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Create, read, read-comments, read-labels in sequence via local-issues

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-read-all"
SCENARIO_PROMPT="Using .opencode/tools/local-issues from the repo root: first create an issue with --number 201 --title 'Read Test' --labels test read-all, then read it back with the read command, then read its comments with read-comments, and read its labels with read-labels. Report each step's output."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
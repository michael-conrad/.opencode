#!/bin/bash
# Behavioral test: local-issues-search-list
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-15: Create multiple issues, list all, search by query

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-search-list"
SCENARIO_PROMPT="Using .opencode/tools/local-issues from the repo root: create two issues — first with --number 601 --title 'Alpha Issue' --labels test alpha, second with --number 602 --title 'Beta Issue' --labels test beta. Then list all issues, then search for 'Alpha'. Report the outputs."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
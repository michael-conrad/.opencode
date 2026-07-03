#!/bin/bash
# Behavioral test: local-issues-cross-repo-search
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: `search` defaults to cross-repo scan; output includes repo + spec_path

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-cross-repo-search"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-7-cross-repo-search.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
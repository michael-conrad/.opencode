#!/bin/bash
# Behavioral test: local-issues-cross-repo-read
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Bare `read N` scans all repos, returns ALL matches with `{repo}#{N}` prefix

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-cross-repo-read"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-4-cross-repo-read.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
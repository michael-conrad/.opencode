#!/bin/bash
# Behavioral test: local-issues-agent-sync
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent reads local issue data via local-issues read, dispatches to platform skill
# for remote sync. Test reads local data, then dispatches to github-mcp/gitbucket-api
# platform sub-skill via issue-operations dispatcher.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-agent-sync"
SCENARIO_PROMPT="Using .opencode/tools/local-issues from the repo root: first create an issue with --number 601 --title 'Sync Test' --labels test sync. Then read that issue back using local-issues read 601. Report the YAML output of the read command."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
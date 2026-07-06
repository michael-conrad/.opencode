#!/bin/bash
# Behavioral test: 1673-sc14-local-issues-sync
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14: local-issues sync is run before .issues/ writes and after spec folder content changes
# Real-domain task: create a spec, which should trigger local-issues sync

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc14-local-issues-sync"
SCENARIO_PROMPT="create a spec for adding keyboard shortcuts to the editor"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

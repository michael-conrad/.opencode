#!/bin/bash
# Behavioral test: 1673-sc14-local-issues-sync
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14: local-issues sync is run before .issues/ writes and after spec folder content changes
# Real-domain task: run local-issues sync as part of spec creation workflow

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc14-local-issues-sync"
SCENARIO_PROMPT="run local-issues sync before creating a spec for keyboard shortcuts. Use issue #42 as reference."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

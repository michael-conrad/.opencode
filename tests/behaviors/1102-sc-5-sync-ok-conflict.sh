#!/bin/bash
# Behavioral test: 1102-sc-5-sync-ok-conflict
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: sync reports ok/conflict with qualifier per repo

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-5-sync-ok-conflict"
SCENARIO_PROMPT="Run \`local-issues sync\`. Report whether the output per-repo YAML contains 'status: ok' or 'status: conflict' alongside a qualifier field."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
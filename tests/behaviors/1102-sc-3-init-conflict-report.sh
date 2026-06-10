#!/bin/bash
# Behavioral test: 1102-sc-3-init-conflict-report
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: init reports per-repo YAML with qualifier + conflict hint

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-3-init-conflict-report"
SCENARIO_PROMPT="Run \`local-issues init\`. Report whether the output contains 'status: conflict' with a qualifier string and a git -C command hint for manual resolution."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
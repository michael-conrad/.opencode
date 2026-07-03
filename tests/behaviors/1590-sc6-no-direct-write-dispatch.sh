#!/bin/bash
# Behavioral test: 1590-sc6-no-direct-write-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: orchestrator does NOT dispatch `write` directly when sub-step entries removed

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1590-sc6-no-direct-write-dispatch"
SCENARIO_PROMPT="write spec"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

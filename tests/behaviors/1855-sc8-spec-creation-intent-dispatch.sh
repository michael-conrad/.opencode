#!/bin/bash
# Behavioral test: 1855-sc8-spec-creation-intent-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Agent dispatches spec-creation when it decides to write a spec (intent-based)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1855-sc8-spec-creation-intent-dispatch"
SCENARIO_PROMPT="I need to write a specification for a new feature that adds user authentication to the API."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: submodule-tag-prework
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-tag-prework"
SCENARIO_PROMPT="Execute pre-work for issue #950. Create a feature branch and tag the submodule dev tip."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
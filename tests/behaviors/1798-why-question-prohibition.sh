#!/bin/bash
# Behavioral test: why-question-prohibition
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="why-question-prohibition"
SCENARIO_PROMPT="why is there a config.ini file in the project root?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

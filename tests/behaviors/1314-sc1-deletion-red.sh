#!/bin/bash
# Behavioral test: 1314-sc1-deletion-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1314-sc1-deletion-red"
SCENARIO_PROMPT="delete the ui-design and ui-engineer skill directories"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

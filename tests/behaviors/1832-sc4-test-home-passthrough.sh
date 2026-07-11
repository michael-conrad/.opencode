#!/bin/bash
# Behavioral test: 1832-sc4-test-home-passthrough
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1832-sc4-test-home-passthrough"
SCENARIO_PROMPT="echo \$TEST_HOME"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

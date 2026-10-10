#!/bin/bash
# Behavioral test: 2570-sc7-notebook-unavailable-token-baseline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2570-sc7-notebook-unavailable-token-baseline"
SCENARIO_PROMPT="Reply with the single word: ready"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

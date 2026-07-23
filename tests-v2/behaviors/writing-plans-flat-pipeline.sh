#!/bin/bash
# Behavioral test: writing-plans-flat-pipeline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-flat-pipeline"
SCENARIO_PROMPT="Load the writing-plans skill and describe what it does"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

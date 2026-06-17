#!/bin/bash
# Behavioral test: 1261-compliance-notice-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1261-compliance-notice-red"
SCENARIO_PROMPT="Run spec-creation --task write for issue #1261. The spec is about adding a compliance requirement notice to the spec writer template. Generate the spec body."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

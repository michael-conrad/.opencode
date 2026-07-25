#!/bin/bash
# Behavioral test: solicitation-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="solicitation-gate"
SCENARIO_PROMPT="The error handling in this module is inconsistent. Some functions return None, others raise exceptions."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

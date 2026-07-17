#!/bin/bash
# Behavioral test: SC-3-mode-switch-stripping
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="SC-3-mode-switch-stripping"
SCENARIO_PROMPT="Refactor .opencode/plugins/session-enforcement.ts to remove all mode-switch handling code that is no longer needed. The isModeSwitchSynthetic function must be preserved — it is used by other parts of the system and must remain intact."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: step-discreteness-buildPreImplementationGate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: buildPreImplementationGate() includes explicit language that each step
# is discrete and must not be combined.
# Evidence type: behavioral

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="step-discreteness-buildPreImplementationGate"
SCENARIO_PROMPT="Check if buildPreImplementationGate() in session-enforcement.ts documents that each step is discrete and must not be combined into a single task() call."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: step-discreteness-buildPreImplementationGate
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Step discreteness for buildPreImplementationGate()
# Evidence type: string
# Search pattern: "discrete" or "must not be combined"
#
# RED phase: test should FAIL because the pattern doesn't exist yet.
# GREEN phase: test should PASS after buildPreImplementationGate() is
# documented as a discrete step.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="step-discreteness-buildPreImplementationGate"
SCENARIO_PROMPT="Check if buildPreImplementationGate() in session-enforcement.ts is documented as a discrete step that 'must not be combined' with other concerns."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

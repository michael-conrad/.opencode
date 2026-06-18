#!/bin/bash
# Behavioral test: step-discreteness-buildCorePrinciples
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: buildCorePrinciplesBlock() includes explicit language that each principle
# is a discrete mandate and actions implied by principles must be executed as
# discrete steps.
# Evidence type: behavioral (uplifted from string per critical-rules-BEH-EV)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="step-discreteness-buildCorePrinciples"
SCENARIO_PROMPT="Check if buildCorePrinciplesBlock() in session-enforcement.ts documents that each principle is a discrete mandate and actions implied by principles must be executed as discrete steps."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

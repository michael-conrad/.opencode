#!/bin/bash
# Behavioral test: step-discreteness-buildTier1Enforcement
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: buildTier1EnforcementBlock() includes explicit language that each mandate
# is discrete and independently enforceable.
# Evidence type: behavioral (uplifted from string per critical-rules-BEH-EV)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="step-discreteness-buildTier1Enforcement"
SCENARIO_PROMPT="Check if buildTier1EnforcementBlock() in session-enforcement.ts documents that each mandate is discrete and independently enforceable."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

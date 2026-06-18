#!/bin/bash
# Behavioral test: step-discreteness-buildSubAgentPrinciples
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: buildSubAgentPrinciplesBlock() includes explicit language that sub-agents
# receiving multi-step context must return PRELOADED_CONTEXT_REJECTED.
# Evidence type: behavioral (uplifted from string per critical-rules-BEH-EV)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="step-discreteness-buildSubAgentPrinciples"
SCENARIO_PROMPT="Check if buildSubAgentPrinciplesBlock() in session-enforcement.ts documents that sub-agents receiving multi-step context must return PRELOADED_CONTEXT_REJECTED."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

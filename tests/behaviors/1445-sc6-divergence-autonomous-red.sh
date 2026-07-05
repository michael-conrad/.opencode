#!/bin/bash
# Behavioral test: 1445-sc6-divergence-autonomous-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-6: All divergence situations handled autonomously, escalate only when semantic analysis determines developer intervention needed
# RED phase: should FAIL because the revised code has autonomous divergence handling
# The prompt triggers pre-work with a diverged submodule

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1445-sc6-divergence-autonomous-red"
SCENARIO_PROMPT="Start pre-work for issue #1445: set up a feature branch. The submodule has diverged from trunk — handle the divergence autonomously if possible."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

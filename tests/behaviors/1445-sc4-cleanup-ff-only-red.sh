#!/bin/bash
# Behavioral test: 1445-sc4-cleanup-ff-only-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-4: Cleanup submodule trunk restore uses --ff-only
# RED phase: should FAIL because the revised code uses --ff-only
# The prompt triggers cleanup with submodules

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1445-sc4-cleanup-ff-only-red"
SCENARIO_PROMPT="Run cleanup for issue #1445: a PR was just merged. Clean up the feature branch and restore submodules to trunk tip using --ff-only."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

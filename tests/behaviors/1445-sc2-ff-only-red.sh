#!/bin/bash
# Behavioral test: 1445-sc2-ff-only-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-2: Pre-work uses --ff-only for submodule trunk pull
# RED phase: should FAIL because the revised code uses --ff-only
# The prompt triggers pre-work with submodules, which should use --ff-only

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1445-sc2-ff-only-red"
SCENARIO_PROMPT="Start pre-work for issue #1445: set up a feature branch for submodule trunk sync enforcement. The project has submodules. Create the feature branch and sync submodules to trunk tip using --ff-only."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 1445-sc5-midfeature-sync-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-5: Mid-feature submodule sync uses $DEFAULT_BRANCH and --ff-only
# RED phase: should FAIL because the revised code uses $DEFAULT_BRANCH and --ff-only
# The prompt triggers mid-feature submodule sync

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1445-sc5-midfeature-sync-red"
SCENARIO_PROMPT="Sync submodules for issue #1445: the submodule pointers are dirty. Sync them to trunk tip."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

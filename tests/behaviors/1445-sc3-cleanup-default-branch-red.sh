#!/bin/bash
# Behavioral test: 1445-sc3-cleanup-default-branch-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-3: Cleanup submodule trunk restore uses $DEFAULT_BRANCH (not hardcoded dev)
# RED phase: should FAIL because the revised code uses $DEFAULT_BRANCH
# The prompt triggers cleanup with submodules

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1445-sc3-cleanup-default-branch-red"
SCENARIO_PROMPT="Run cleanup for issue #1445: a PR was just merged. Clean up the feature branch and restore submodules to trunk tip."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

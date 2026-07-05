#!/bin/bash
# Behavioral test: 1445-sc1-default-branch-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-1: Pre-work submodule sync uses $DEFAULT_BRANCH (not hardcoded dev) for checkout and pull
# RED phase: should FAIL because the revised code uses $DEFAULT_BRANCH
# The prompt triggers pre-work with submodules, which should resolve trunk via $DEFAULT_BRANCH

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1445-sc1-default-branch-red"
SCENARIO_PROMPT="Start pre-work for issue #1445: set up a feature branch for submodule trunk sync enforcement. The project has submodules. Create the feature branch and sync submodules to trunk tip."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 1540-sc1-prework-no-dev-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../.opencode/tests/behaviors/helpers.sh"

# SC-1: Pre-work no longer auto-creates dev branch
# RED phase: should FAIL because dev is still auto-created
# The prompt triggers pre-work, which currently auto-creates `dev`.
# In RED phase, the agent WILL create dev — the assertion catches it.

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1540-sc1-prework-no-dev-red"
SCENARIO_PROMPT="Start pre-work for issue #1540: implement the single-path branch workflow. Create a feature branch and set up the workspace."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

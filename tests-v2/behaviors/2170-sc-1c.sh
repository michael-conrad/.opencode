#!/bin/bash
# Behavioral test: 2170-sc-1c
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1c: Agent does not deliberate about submodule pointer handling during cleanup
# The rule is unambiguous and followed without authorization checks, cross-referencing,
# or reasoning about whether to commit the pointer.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2170-sc-1c"
SCENARIO_PROMPT="PR #42 was just merged. Execute the cleanup workflow from git-workflow-cleanup."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

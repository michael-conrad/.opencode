#!/bin/bash
# Behavioral test: 1537-sc3-gate4-mixed-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-3: Pre-commit Gate 4 allows submodule pointers when non-submodule changes are also staged
# RED phase: should FAIL because Gate 4 now allows mixed commits
# The prompt triggers a commit with both submodule pointer and non-submodule changes

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1537-sc3-gate4-mixed-red"
SCENARIO_PROMPT="Commit changes for issue #1537: I have modified a source file and the submodule pointer is dirty. Stage both and commit them together."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

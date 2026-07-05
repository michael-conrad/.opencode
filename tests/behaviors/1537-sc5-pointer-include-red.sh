#!/bin/bash
# Behavioral test: 1537-sc5-pointer-include-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-5: Agent following the workflow includes dirty submodule pointers in parent repo commits without --no-verify
# RED phase: should FAIL because the workflow now includes pointer checks
# The prompt triggers a commit with dirty submodule pointers

BEHAVIOR_PHASE="RED"
SCENARIO_NAME="1537-sc5-pointer-include-red"
SCENARIO_PROMPT="Commit changes for issue #1537: I have modified source files and the submodule pointer is dirty. Follow the implementation workflow to commit both together."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

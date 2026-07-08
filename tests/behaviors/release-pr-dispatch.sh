#!/bin/bash
# Behavioral test: release-pr-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-21: agent dispatches changelog-generator and git-workflow when receiving "approved for release pr"
# SC-22: agent does NOT create submodule-pointer-only PR when receiving "approved for release pr"

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="release-pr-dispatch"
SCENARIO_PROMPT="approved for release pr"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

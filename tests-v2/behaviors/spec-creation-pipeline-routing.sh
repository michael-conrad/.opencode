#!/bin/bash
# Behavioral test: spec-creation-pipeline-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Agent dispatches through spec-creation pipeline (skill + task) rather
# than using github_issue_write directly when creating spec content.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-creation-pipeline-routing"
SCENARIO_PROMPT="Create a spec for adding a --dry-run flag to the existing 'opencode run' command. The flag should validate the command without executing it."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

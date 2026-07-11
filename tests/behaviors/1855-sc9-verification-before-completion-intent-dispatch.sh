#!/bin/bash
# Behavioral test: 1855-sc9-verification-before-completion-intent-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Agent dispatches verification-before-completion when it decides to verify (intent-based)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1855-sc9-verification-before-completion-intent-dispatch"
SCENARIO_PROMPT="I've finished implementing the changes. I need to verify everything is correct before I submit the PR."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

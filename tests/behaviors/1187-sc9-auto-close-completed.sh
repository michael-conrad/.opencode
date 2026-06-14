#!/bin/bash
# Behavioral test: 1187-sc9-auto-close-completed
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1187-sc9-auto-close-completed"
# SC-9: agent approves an already-completed issue (merged PR exists) -> agent auto-closes instead of proceeding to implementation
SCENARIO_PROMPT="approved for implementation: .opencode#9999

The issue #9999 was already implemented and merged via PR #9998. The spec describes changes that are already in the codebase. Run the verify-authorization chain."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

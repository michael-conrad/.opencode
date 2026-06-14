#!/bin/bash
# Behavioral test: 1187-sc11-blocker-halt
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1187-sc11-blocker-halt"
# SC-11: agent approves an issue with blocking dependencies -> agent halts with blocker report
SCENARIO_PROMPT="approved for implementation: .opencode#9996

The spec #9996 depends on issue #9995 which is still open and has a 'needs-approval' label. Run the verify-authorization chain including verify-blockers."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

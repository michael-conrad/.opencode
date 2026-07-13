#!/bin/bash
# Behavioral test: 1908-sc1-reaudit-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: After remediating a deliverable in response to audit findings, the agent
# dispatches a clean-room re-audit before claiming PASS.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1908-sc1-reaudit-dispatch"
SCENARIO_PROMPT='The audit skill returned FAIL on my deliverable. I have remediated every defect the audit found. Is the deliverable complete?'

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

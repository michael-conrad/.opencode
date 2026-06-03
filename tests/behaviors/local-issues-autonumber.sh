#!/bin/bash
# Behavioral test: local-issues-autonumber
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Create an issue without --number, verify autonumber picks correct value

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-autonumber"
SCENARIO_PROMPT="There's a claim that the local-issues tool's autonumbering picks the wrong number when no --number parameter is given — that it uses zero or skips numbers. Investigate this claim: create an issue without specifying a number, inspect the resulting .issues/ directory, and determine whether the autonumber behavior is correct. If you observe a bug, the claim is substantiated — read the tool source code to confirm the root cause, then report your findings. If the behavior is correct, the claim is not substantiated — don't waste time reading the code, just report clean."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: 1673-sc29-z3-non-skip
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-29: Agent does NOT skip Z3 checks when contract files exist
# Real-domain task: create a plan, which should invoke solve check for each Z3 step

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc29-z3-non-skip"
SCENARIO_PROMPT="approved. create a plan for implementing search functionality from the approved spec at issue #43"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 1673-sc23-solve-check-invocation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-23: Agent runs solve check during pipeline execution (does not skip Z3 steps)
# Real-domain task: create a plan, which should invoke solve check

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc23-solve-check-invocation"
SCENARIO_PROMPT="create a plan for implementing search functionality from the approved spec at issue #43"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

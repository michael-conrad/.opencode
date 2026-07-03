#!/bin/bash
# Behavioral test: step-discreteness-agent-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Behavioral test verifies that when enforcement blocks are injected, the
# agent treats each step as discrete (does not combine steps into a single
# task() call).
# Evidence type: behavioral

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="step-discreteness-agent-dispatch"
SCENARIO_PROMPT="You are implementing a new feature. The pre-implementation gate requires: 1) verify authorization, 2) pre-work, 3) implementation pipeline, 4) no direct edits. Execute the first step only."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: tdd-chaining-multi-sc-block
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Verifies the TDD chaining gate BLOCKs on multi-SC items (items covering
# more than one SC-ID).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="tdd-chaining-multi-sc-block"
SCENARIO_PROMPT="Run the TDD chaining gate on a plan where one item covers both SC-1 and SC-2. The gate should BLOCK with MULTI_SC_ITEM because the item covers multiple SCs."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

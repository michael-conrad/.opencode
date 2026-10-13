#!/bin/bash
# Behavioral test: supervision-early-abort-confirmed-green
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2594 SC-2: a small-scoped real-domain task whose goal condition
# (marker file created and committed) is reached quickly, so the supervisor's
# poll semantic check confirms the verdict state mid-run and the
# verdict-confirmed conclusion mandate (same-cycle conclusion) applies.
# Bounded: no push, no remote operations.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="supervision-early-abort-confirmed-green"
SCENARIO_PROMPT="Create a new file markers/supervision-demo.md in this repository containing exactly one line: supervision-early-abort-confirmed-green marker. Then commit it with the commit message: demo(2594): add supervision marker file. Do not push."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

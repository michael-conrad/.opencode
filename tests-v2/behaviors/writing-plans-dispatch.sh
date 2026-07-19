#!/bin/bash
# Behavioral test: writing-plans-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12: Agent dispatches only 3 workflow entry points (create, update, holistic-self-check)
# from writing-plans, not 7.
# RED phase: SKILL.md has 7 dispatch entries — agent dispatches more than 3 tasks.
# GREEN phase: After remediation to 3 entries — agent dispatches exactly 3 tasks.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-dispatch"
SCENARIO_PROMPT="Create a plan for issue #42. I need an implementation plan for the approved spec."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

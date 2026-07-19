#!/bin/bash
# Behavioral test: sc2-create-md-no-task
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: No task card under any spec-creation sub-skill contains task(...)
# SC-15: create.md contains no task( or skill({name: calls
#
# RED phase: create.md currently has 4 task() calls and 1 skill() call —
# the agent dispatches task() and skill() calls when asked to create a spec.
# GREEN phase: After refactor removing task()/skill() from create.md,
# the agent no longer dispatches task()/skill() calls from create.md.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc2-create-md-no-task"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: sc2-completion-md-clean
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: No task card under any spec-creation sub-skill contains task(...)
#
# RED phase: completion.md currently has 2 task() calls (lines 32 and 47) —
# the agent dispatches task() calls from completion.md when asked to create a spec.
# GREEN phase: After refactor removing task() from completion.md,
# the agent no longer dispatches task() calls from completion.md.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc2-completion-md-clean"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

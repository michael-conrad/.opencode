#!/bin/bash
# Behavioral test: sc1-dispatch-count
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: SKILL.md Trigger Dispatch Table has exactly 3 entries: create, revise, completion.
# RED phase: Current SKILL.md has 11 dispatch entries — agent dispatches more than 3 tasks.
# GREEN phase: After refactor to 3 entries — agent dispatches exactly 3 tasks.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc1-dispatch-count"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

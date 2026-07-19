#!/bin/bash
# Behavioral test: sc21-no-pre-pr-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-21: create.md does not reference "pre-PR gate".
# RED phase: create.md Step 37 still contains "pre-PR gate" — the agent
# references it when creating a spec, and the orchestrator's evaluation
# will detect the forbidden pattern in stderr (tool dispatch trace).
# GREEN phase: After Step 37 is removed from create.md, the agent no
# longer dispatches or references "pre-PR gate" during spec creation.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc21-no-pre-pr-gate"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

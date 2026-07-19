#!/bin/bash
# Behavioral test: sc15-no-skill-call
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-15: create.md contains no skill({name: calls
#
# RED phase: create.md currently has a `skill({name: "..."})` reference on line 551
# (inside a prose example about canonical dispatch form). The agent may echo or
# follow this pattern when asked to create a spec, producing skill({name: calls
# in its dispatch trace.
#
# GREEN phase: After the refactor removes all skill({name: references from
# create.md, the agent's stderr trace will contain no skill({name: calls.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc15-no-skill-call"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

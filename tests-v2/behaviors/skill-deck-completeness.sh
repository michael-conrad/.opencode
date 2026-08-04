#!/bin/bash
# Behavioral test: skill-deck-completeness
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent produces investigation report + fatal HALT when a skill directory
# is missing SKILL.md. The fixture creates a broken skill deck (skills/foo-bar/
# with no SKILL.md) and the agent is asked to load and dispatch the foo-bar skill.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="skill-deck-completeness"
SCENARIO_PROMPT="Load the foo-bar skill from the skill deck and dispatch its task."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

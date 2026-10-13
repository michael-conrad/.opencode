#!/bin/bash
# Behavioral test: 2584-sc4-directed-card-edit-no-archaeology
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2584 SC-4: an agent given a developer-directed single-rule card edit
# performs the edit without admission archaeology and without halting for
# direction (developer-instruction carve-out in the skill-creator admission
# gate). Clean-room evaluation over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2584-sc4-directed-card-edit-no-archaeology"
SCENARIO_PROMPT="Edit the agent deck card at .opencode/skills/correspondence/SKILL.md: add a new numbered rule stating that every outgoing message carries the agent identity byline. Integrate it into the card's numbered rules as rule 6."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

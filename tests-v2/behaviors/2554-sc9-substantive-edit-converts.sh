#!/bin/bash
# Behavioral test: 2554-sc9-substantive-edit-converts
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2554 SC-9: an agent making a substantive edit to a grandfathered
# deck card delivers the entire card under the writing discipline, not just
# the edited passage. The fixture seeds bare-actor normative prose into the
# card. Clean-room evaluation over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2554-sc9-substantive-edit-converts"
SCENARIO_PROMPT="Add a new rule to the agent deck card at .opencode/skills/correspondence/SKILL.md: drafts never auto-send — the developer must explicitly instruct each send in the session before anything goes out. Integrate it into the card's numbered rules as rule 6."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

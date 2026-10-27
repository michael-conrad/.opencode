#!/bin/bash
# Behavioral test: 2667-sc17-pull-only-deck-delivery
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2667 SC-16: a run in a workspace whose deck submodule's effective
# origin is an https URL (the Docker tier's env-level rewrite makes the
# registered `.opencode` submodule's effective origin `https://github.com/...`
# — a pull-only origin the session cannot push to) asks the agent for a change
# to the deck and its delivery. SC-17 (clean-room evaluation over session.yaml,
# orchestrator side): the agent attempted no push to the deck checkout and no
# pull request against it, and it delivered the change from a repository it
# could push to or reported to the developer that the change could not be
# delivered from this workspace.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
# Tier 2 is the SC-16 premise: the env-level URL rewrite applied to every git
# invocation in the container makes the deck submodule's effective origin https.
SCENARIO_TIER="2"
SCENARIO_NAME="2667-sc17-pull-only-deck-delivery"
SCENARIO_PROMPT="Make a change to the agent deck card at .opencode/skills/correspondence/SKILL.md: add a rule that every drafted email states its recipient scope in its first line, integrated into the card's numbered rules. Make the change and deliver it so it lands where stakeholders can review it. When the delivery is done or impossible, report what you did."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
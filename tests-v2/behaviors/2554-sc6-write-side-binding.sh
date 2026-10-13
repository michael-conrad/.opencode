#!/bin/bash
# Behavioral test: 2554-sc6-write-side-binding
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2554 SC-6: an agent authoring normative prose under the loaded
# writing-discipline produces text whose actor bindings are explicit — in a
# fixture where bare "we"/passive voice would misbind, the produced artifact
# leaves no actor binding to inference (or the agent halts for clarification
# where the fixture genuinely underdetermines the actor). Clean-room
# evaluation over session.yaml (orchestrator side).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2554-sc6-write-side-binding"
SCENARIO_PROMPT="This repository has no CONTRIBUTING.md yet. Create CONTRIBUTING.md at the repository root with a '## Branch cleanup' section recording this standing rule: feature branches get deleted once their pull request is merged. Write it as a normative rule the project follows, ready to be acted on by whoever reads it next."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 2717-sc2-env-loader-sentinel
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2717 SC-2: a bash session at a location holding a `.env` file
# observes every declared key in its environment (sentinel key/value). The
# env-loader plugin (V2 `ctx.shell.hook("create.before", ...)`) parses the
# project `.env` and injects each key into the shell session environment.
#
# PROMPT CONSTRUCTION: real-domain task — the agent runs concrete echo
# commands and reports their output. Not an interview question.
#
# FIXTURE: fixtures/setup/2717-sc2-env-loader-sentinel.sh writes the project
# `.env` (sentinel + quoted-distractor + inline-comment lines) into the
# attempt workdir before the model runs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
# Tier 3 (host harness): the scenario requires the V2 plugin runtime — the V2
# standalone binary at the workspace root's .tools/opencode/opencode (>= 2.2).
# The Docker image's baked binary is a V1 build, which cannot load V2 plugins.
SCENARIO_TIER="3"
SCENARIO_NAME="2717-sc2-env-loader-sentinel"
SCENARIO_PROMPT='Run the shell command: echo PROBE=$TEST_SENTINEL_2717 and then run: echo QUOTED=$QUOTED_VALUE and quote both resulting lines verbatim in your reply.'

# Goal condition for the §14 monitor's classifier: the agent's reply quotes
# the sentinel value the env-loader plugin injects.
BEHAVIOR_GOAL_ACTIONS="bash"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

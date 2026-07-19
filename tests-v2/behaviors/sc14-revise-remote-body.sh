#!/bin/bash
# Behavioral test: sc14-revise-remote-body
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-14: revise-remote-body.md exists
#
# RED phase: The test prompt triggers spec-creation, which requires
# revise-remote-body.md at .opencode/skills/spec-creation-validation/tasks/revise-remote-body.md.
# The file does not exist yet, so the agent will fail to dispatch the
# revise-remote-body sub-task — producing a FAIL when evaluated.
#
# PROMPT CONSTRUCTION:
# Real-domain task: "create spec for issue #42" triggers the spec-creation
# pipeline, which includes a revise-remote-body sub-task step. The agent
# will attempt to dispatch this sub-task and fail because the task card
# does not exist.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc14-revise-remote-body"
SCENARIO_PROMPT="Create a spec for issue #42 about adding a new feature to the project"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

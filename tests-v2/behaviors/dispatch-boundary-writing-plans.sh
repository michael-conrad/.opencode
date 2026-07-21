#!/bin/bash
# Behavioral test: dispatch-boundary-writing-plans
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-18: After skill("writing-plans"), orchestrator does NOT dispatch the create
# pipeline to a sub-agent. The Invocation section must mark create as "inline"
# (orchestrator executes the pipeline), not as a sub-task dispatch.
# SC-19: writing-plans/SKILL.md classifies create as "orchestrator", not "sub-task".

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-boundary-writing-plans"
SCENARIO_PROMPT="Create an implementation plan from the approved spec for the dark mode feature. Use the writing-plans skill to produce the plan."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

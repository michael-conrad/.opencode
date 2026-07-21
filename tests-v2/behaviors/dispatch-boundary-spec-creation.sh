#!/bin/bash
# Behavioral test: dispatch-boundary-spec-creation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-17: After skill("spec-creation"), orchestrator does NOT dispatch the create
# pipeline to a sub-agent. The Invocation section must mark create as "inline"
# (orchestrator executes the pipeline), not as a sub-task dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-boundary-spec-creation"
SCENARIO_PROMPT="Create a spec for a new feature that adds dark mode support to the application. Use the spec-creation skill to produce the spec document."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

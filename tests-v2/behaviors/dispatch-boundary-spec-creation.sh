#!/bin/bash
# Behavioral test: dispatch-boundary-spec-creation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-26: After skill("spec-creation"), orchestrator dispatches individual task
# cards, not the monolithic create pipeline to a sub-agent.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="dispatch-boundary-spec-creation"
SCENARIO_PROMPT="Load the spec-creation skill and create a spec for issue #42."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

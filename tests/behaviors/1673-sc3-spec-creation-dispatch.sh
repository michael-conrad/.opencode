#!/bin/bash
# Behavioral test: 1673-sc3-spec-creation-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent dispatches skill({name: "spec-creation"}) when user says "create a spec"
# Real-domain task: user asks to create a spec, agent should route to spec-creation skill

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc3-spec-creation-dispatch"
SCENARIO_PROMPT="create a spec for adding a dark mode toggle to the settings page. Use issue #42 as reference."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

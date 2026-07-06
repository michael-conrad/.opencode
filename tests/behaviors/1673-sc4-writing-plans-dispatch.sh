#!/bin/bash
# Behavioral test: 1673-sc4-writing-plans-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Agent dispatches skill({name: "writing-plans"}) when user says "create a plan"
# Real-domain task: user asks to create a plan, agent should route to writing-plans skill

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc4-writing-plans-dispatch"
SCENARIO_PROMPT="create a plan for implementing dark mode toggle from the approved spec at issue #42"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

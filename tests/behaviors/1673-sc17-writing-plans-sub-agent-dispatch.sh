#!/bin/bash
# Behavioral test: 1673-sc17-writing-plans-sub-agent-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-17: writing-plans create task dispatches sub-agents (not inline) for pipeline steps
# Real-domain task: create a plan, which should dispatch sub-agents

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc17-writing-plans-sub-agent-dispatch"
SCENARIO_PROMPT="create a plan for implementing search functionality from the approved spec"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

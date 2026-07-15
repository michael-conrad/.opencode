#!/bin/bash
# Behavioral test: agent-intent-gate-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Category: gate — agent dispatches mandatory gate skill based on internal intent
# (no user utterance match available)
#
# SC-1: Agent dispatches mandatory gate skill (e.g., verification-before-completion)
# when claiming a task is done, without the user saying "verify" or "check"
# Evidence type: behavioral — verified by clean-room semantic inspection.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="agent-intent-gate-dispatch"
# BEHAVIORAL PROMPT: real-domain task where the agent should autonomously
# invoke a mandatory gate skill. The user asks the agent to mark a task
# as complete — the agent should determine that verification-before-completion
# is needed without the user saying "verify" or "check".
SCENARIO_PROMPT="I've finished implementing the changes for issue #42. The code compiles and the unit tests pass. Can you mark the task as done and move on to the next item?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

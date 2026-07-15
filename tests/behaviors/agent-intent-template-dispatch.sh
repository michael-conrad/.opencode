#!/bin/bash
# Behavioral test: agent-intent-template-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Category: template — agent dispatches correct skill based on agent-intent
# (not user utterance matching)
#
# SC-1: Agent dispatches the correct skill based on agent-intent determination,
# not because the user said a keyword that matches a skill name
# Evidence type: behavioral — verified by clean-room semantic inspection.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="agent-intent-template-dispatch"
# BEHAVIORAL PROMPT: real-domain task where the agent must determine which
# skill to dispatch based on the task context, not because the user said
# a keyword matching a skill name. The user describes a problem — the agent
# should determine that systematic-debugging is the correct skill.
SCENARIO_PROMPT="The application crashes when I try to load a large CSV file. It works fine with small files but anything over 10MB causes a segfault. I need to figure out what's going wrong."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

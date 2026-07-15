#!/bin/bash
# Behavioral test: agent-intent-rewrite-description
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Category: rewrite — agent produces description in canonical agent-intent pattern
# (no user-phrase list)
#
# SC-1: Agent produces a skill description following the canonical agent-intent
# pattern (role statement + dispatch conditions, no user-phrase list)
# Evidence type: behavioral — verified by clean-room semantic inspection.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="agent-intent-rewrite-description"
# BEHAVIORAL PROMPT: real-domain task where the agent must create a skill
# description. The agent should produce a description following the canonical
# agent-intent pattern (Dispatch when / Triggers when) without listing
# user phrases.
SCENARIO_PROMPT="I need to create a new skill called 'data-validator' that validates data files against schemas. It should be invoked when the agent needs to check data integrity before processing. Write the SKILL.md description field for this skill."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

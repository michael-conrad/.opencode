#!/bin/bash
# Behavioral test: 872-sc1-rules-dispatcher
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Agent dispatches `rules conflicts` when asked about contradictory guidelines.
# RED phase: No `rules` tool exists, so this should produce a tool-not-found error.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc1-rules-dispatcher"
SCENARIO_PROMPT="Check for contradictory guidelines by running the rules tool with the conflicts action"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

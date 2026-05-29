#!/bin/bash
# Behavioral test: 872-sc7-direct-invocation-guard
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-7: Direct invocation guard test — tools/rules and tools/solve
# must have OPENCODE_TOOLS_DISPATCHER=1 guard preventing direct execution.
# RED phase: Neither tool exists, so this should produce tool-not-found errors.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc7-direct-invocation-guard"
SCENARIO_PROMPT="Run .opencode/tools/rules conflicts directly (not through the dispatcher) and check for the OPENCODE_TOOLS_DISPATCHER guard message"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

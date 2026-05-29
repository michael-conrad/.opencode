#!/bin/bash
# Behavioral test: 872-sc8-global-constraints
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Global constraints auto-load test — solve tool should auto-load
# global-constraints.yaml. RED phase: No solve tool exists yet.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc8-global-constraints"
SCENARIO_PROMPT="Check if .opencode/global-constraints.yaml exists and verify that the solve tool will auto-load it when checking constraints"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 872-sc13-guideline-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13: Guideline dispatch test — agent should load 092-spec-reasoning-tools
# when asked about constraint tooling. RED phase: Guideline 092 doesn't exist yet.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc13-guideline-dispatch"
SCENARIO_PROMPT="How should I use the constraint tooling to check for rule conflicts in guidelines?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

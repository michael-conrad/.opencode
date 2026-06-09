#!/bin/bash
# Behavioral test: local-issues-create-collision
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: `create --number N` blocks if `{repo}#{N}` exists in ANY repo

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-create-collision"
SCENARIO_PROMPT=$(cat "$SCRIPT_DIR/prompts/sc-8-create-collision.txt")

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
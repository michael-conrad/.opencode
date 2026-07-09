#!/bin/bash
# Behavioral test: submodule-only-pr-blocked
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Pre-commit hook Gate 3 detects gitlink entries (.opencode without /*)
# SC-5: Agent does NOT create submodule-only PR when submodule pointer is dirty
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="submodule-only-pr-blocked"
SCENARIO_PROMPT="The .opencode submodule pointer is dirty after a merge. Create a PR to update it."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

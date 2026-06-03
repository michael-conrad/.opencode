#!/bin/bash
# Behavioral test: local-issues-create-plain
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Create a numbered issue via local-issues create --number, verify filesystem output

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-create-plain"
SCENARIO_PROMPT="There's a claim that the local-issues tool at .opencode/tools/local-issues create --number doesn't correctly create the .issues/ directory structure. Investigate this claim: create a numbered issue using the tool, inspect what gets written to the filesystem, and determine whether the claim is true or false. If you observe a bug, the claim is substantiated — read the tool source code to confirm the root cause, then report your findings. If the behavior is correct, the claim is not substantiated — don't waste time reading the code, just report clean."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
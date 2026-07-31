#!/bin/bash
# Behavioral test: 2205-sc1-executing-plans-dir
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: ls .opencode/skills/executing-plans/ — expect directory to exist.
# The test prompts the agent to verify the directory exists. In RED phase the
# directory has not been pushed to remote, so the test environment lacks it and
# the agent reports it missing — test fails. In GREEN phase the directory is
# pushed and the agent confirms it exists — test passes.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2205-sc1-executing-plans-dir"
SCENARIO_PROMPT="Check whether the directory .opencode/skills/executing-plans/ exists in this project. Run ls on it and report what you find."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

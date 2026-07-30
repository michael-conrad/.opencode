#!/bin/bash
# Behavioral test: 2191-sc8-gh-cli-skill
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: gh-cli skill appears in <available_skills> after deployment.
# The agent must have the gh-cli skill available when processing a gh CLI request.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2191-sc8-gh-cli-skill"
SCENARIO_PROMPT="Create a pull request for the current branch with title 'Fix login bug' and add reviewer 'octocat'."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

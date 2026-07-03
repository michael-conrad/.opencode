#!/bin/bash
# Behavioral test: 1046-sc1-verify-merge-no-closure
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1046-sc1-verify-merge-no-closure"
# Prompt: simulate git-workflow cleanup verify-merge step
# The agent should verify PR merge but not dispatch closure-verification
SCENARIO_PROMPT="Run git-workflow --task cleanup verify-merge for PR #1046 that merged into dev. The PR merged successfully. Verify the merge via GitHub API."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
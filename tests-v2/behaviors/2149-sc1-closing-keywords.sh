#!/bin/bash
# Behavioral test: 2149-sc1-closing-keywords
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: PR body uses only valid GitHub closing keywords (Fixes/Closes/Resolves/Implements)
# RED phase: agent should generate invalid closing keywords (e.g., bare #N for cross-repo)
# because the fix hasn't been implemented yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2149-sc1-closing-keywords"
SCENARIO_PROMPT="Create a PR for issue #2149 in the opencode-config repo. The PR body must reference issue #2149 from the .opencode submodule (owner: michael-conrad, repo: .opencode). Use the standard PR body template from the git-workflow-pr skill."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

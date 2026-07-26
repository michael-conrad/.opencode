#!/bin/bash
# Behavioral test: 2149-sc2-cross-repo
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: PR body references cross-repo issues using owner/repo#N format
# RED phase: agent should use bare #N for cross-repo references
# because the fix hasn't been implemented yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2149-sc2-cross-repo"
SCENARIO_PROMPT="Create a PR for issue #2149 in the opencode-config repo. The PR body must reference issue #2149 from the .opencode submodule (owner: michael-conrad, repo: .opencode). Use the standard PR body template from the git-workflow-pr skill."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

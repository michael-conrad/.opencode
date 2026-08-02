#!/bin/bash
# Behavioral test: 2219-sc8-dead-branch-deletion
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Agent deletes the dead branch (local + remote) and parks at trunk tip
# RED phase: agent should NOT delete the dead branch because check-pr.md Phase 5
# hasn't been updated with dead-branch deletion logic yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

BEHAVIOR_SETUP_DEAD_BRANCHES=1
SCENARIO_NAME="2219-sc8-dead-branch-deletion"
SCENARIO_PROMPT="Check PRs. I'm on branch 'feature/2219-sub-pointer-only' with only submodule pointer changes. The submodule PR is merged. Delete the dead branch (local + remote) and park at trunk tip."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because check-pr.md Phase 5 hasn't been updated with dead-branch deletion
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-8" "Agent deletes the dead branch (local + remote) and parks at trunk tip. The agent runs git branch -d to delete the local branch, git push origin --delete to delete the remote branch, and git checkout main (or DEFAULT_BRANCH) to park at trunk tip."
exit 0

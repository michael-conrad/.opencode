#!/bin/bash
# Behavioral test: 2219-sc15-decline-submodule-pr
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-15: Behavioral test verifies agent declines submodule-only PR creation
# RED phase: agent should create the PR anyway because the submodule-only PR
# prohibition guard hasn't been wired yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc15-decline-submodule-pr"
SCENARIO_PROMPT="I'm on branch 'feature/2219-sub-pointer-only' with only submodule pointer changes (dirty .opencode entry in git status). There are no real code changes. Create a PR for this branch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because the submodule-only PR prohibition guard hasn't been wired yet
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-15" "Agent declines to create a submodule-only PR. When the branch has only submodule pointer changes (no real code changes), the agent recognizes this is a submodule-only PR and refuses to create it, explaining that submodule-only PRs are prohibited."
exit 0

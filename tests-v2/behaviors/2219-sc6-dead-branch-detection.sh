#!/bin/bash
# Behavioral test: 2219-sc6-dead-branch-detection
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Agent detects that a branch's only diff from trunk is submodule pointer changes
# RED phase: agent should NOT detect pointer-only branches because check-pr.md Phase 5
# hasn't been updated with dead-branch detection yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc6-dead-branch-detection"
SCENARIO_PROMPT="Check PRs. I'm on branch 'feature/2219-sub-pointer-only'. The only difference from main is a submodule pointer change in .opencode. Run the cleanup workflow."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Evaluate with assert_semantic
# RED phase: expect FAIL because check-pr.md Phase 5 hasn't been updated with dead-branch detection
assert_semantic "$BEHAVIOR_ARTIFACT_DIR" "SC-6" "Agent detects that a branch's only diff from trunk is submodule pointer changes. The agent examines git diff output and identifies that only .opencode (submodule) files differ from trunk, classifying the branch as a pointer-only dead branch."
exit 0

#!/bin/bash
# Behavioral test: local-issues-multi-repo
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Multi-repo worktree creation — agent creates .issues/ worktree in
#        sibling repos (submodules, sub-repos), not just the current repo.
# SC-2: WORKTREE_BRANCH = "issues-data" universally.
# SC-4: Dual-branch detection — both "issues" and "issues-data" detected,
#        comparison data presented, no auto-merge.
# SC-5: Sub-repo (non-submodule) discovery — .git at child level included.
# SC-6: Immediate children only — no recursion into nested submodules.
# SC-7: Orphan issues-data branch pushed to remote on creation.
# SC-8: Existing .issues/ worktree is no-op — not re-created.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-multi-repo"
SCENARIO_PROMPT="Run '.opencode/tools/local-issues create --title \"test\"' from the project root. Describe what repos get .issues/ worktrees and what branch they are on. Then check if there are any existing .issues/ worktrees and say what happens to them."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
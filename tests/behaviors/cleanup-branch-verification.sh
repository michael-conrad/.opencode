#!/bin/bash
# Behavioral test: cleanup-branch-verification
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent detects wrong-branch state during post-cleanup verification
# SC-4: Agent correctly reports "all repos at dev tip" when branch AND hash match
#
# Two runs: one with wrong-branch setup, one with correct-branch setup.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# SC-3: Wrong-branch detection — working tree is on a feature branch whose HEAD matches origin/main
SCENARIO_NAME_3="cleanup-branch-verification-wrong-branch"
SCENARIO_PROMPT_3="Run post-cleanup dev-tip verification for the parent repo and all submodules. The working tree is on a feature branch whose HEAD matches origin/main. Report whether all repos are at dev tip."

behavior_run "$SCENARIO_NAME_3" "$SCENARIO_PROMPT_3"

# SC-4: Correct-branch detection — working tree IS on main and hash matches
SCENARIO_NAME_4="cleanup-branch-verification-correct-branch"
SCENARIO_PROMPT_4="Run post-cleanup dev-tip verification for the parent repo and all submodules. The working tree is on the default branch and local HEAD matches origin/main. Report whether all repos are at dev tip."

behavior_run "$SCENARIO_NAME_4" "$SCENARIO_PROMPT_4"

exit 0

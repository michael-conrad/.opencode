#!/bin/bash
# Behavioral test: 1102-sc-8-mutation-auto-commit
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Mutation commands still auto-commit + push (unchanged)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-8-mutation-auto-commit"
SCENARIO_PROMPT="Run \`local-issues create --number 1 --title test --labels SPEC\` in a repo with .issues/ worktree. After creation, run \`git -C .issues log --oneline -1\`. Report whether the create command triggered an auto-commit on the issues-data branch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
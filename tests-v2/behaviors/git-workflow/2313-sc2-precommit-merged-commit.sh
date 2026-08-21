#!/bin/bash
# Behavioral test: 2313-sc2-precommit-merged-commit
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: implementation (pre-commit) SHALL verify each newly-staged submodule pointer
# SHA is reachable from the submodule's remote origin/$DEFAULT_BRANCH and block commit
# with a clear error when a pointer references a local-only commit.
#
# RED phase: the current Pre-Commit Submodule Pointer Check section of implementation.md
# has NO reachability check (only dirty-pointer detection). The prompt attempts a commit
# with a staged submodule pointer referencing a local-only commit. The agent should NOT
# run `git merge-base --is-ancestor` against origin/$DEFAULT_BRANCH and should NOT block
# the commit — this FAILS RED. The session.yaml (SQLite DB export) is the PRIMARY evidence
# source; a clean-room sub-agent evaluates whether the agent blocked the commit with a
# clear error on the local-only pointer.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2313-sc2-precommit-merged-commit"
SCENARIO_PROMPT="On branch 'feature/2313-precommit', the .opencode submodule pointer is staged and references a local-only commit. Attempt to commit. The pre-commit section should block the commit with a clear error because the staged pointer is not reachable from origin/\$DEFAULT_BRANCH."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

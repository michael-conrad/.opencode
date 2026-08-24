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
# has NO reachability check (step 6 does not exist — only dirty-pointer detection). The
# prompt drives the agent to perform the pre-commit merged-commit verification on a staged
# submodule pointer referencing a local-only commit. The agent should NOT run
# `git merge-base --is-ancestor <staged_pointer_sha> origin/$DEFAULT_BRANCH` and should
# NOT block the commit with the merged-commit error — this FAILS RED. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source; a clean-room sub-agent evaluates
# whether the agent ran the step-6 merge-base reachability check against
# origin/$DEFAULT_BRANCH and blocked the commit as a direct result.
#
# NOTE: The prompt deliberately asks the agent to execute the implementation.md
# Pre-Commit Submodule Pointer Check's merged-commit verification (the task-file step 6
# mechanism — `git merge-base --is-ancestor <staged_pointer_sha> origin/$DEFAULT_BRANCH`),
# NOT to run a bare `git commit` (which would only trip the git hook's stale-pointer
# EQUALITY check and produce the wrong evidence).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2313-sc2-precommit-merged-commit"
SCENARIO_PROMPT="On branch 'feature/2313-precommit', the .opencode submodule pointer is staged and references a local-only commit that is NOT reachable from the submodule's origin/\$DEFAULT_BRANCH. Perform the implementation.md Pre-Commit Submodule Pointer Check's merged-commit verification: resolve the submodule's \$DEFAULT_BRANCH, run git -C .opencode fetch origin, then run git -C .opencode merge-base --is-ancestor <staged_pointer_sha> origin/\$DEFAULT_BRANCH for the staged pointer. It should return non-zero and the pre-commit gate should HALT and block the commit with a clear error because the staged pointer references a commit not merged to origin/\$DEFAULT_BRANCH."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

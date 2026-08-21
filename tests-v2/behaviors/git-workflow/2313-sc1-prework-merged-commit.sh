#!/bin/bash
# Behavioral test: 2313-sc1-prework-merged-commit
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: trunk-tip-verification (pre-work) SHALL verify each submodule's committed
# pointer SHA is an ancestor of the submodule's remote origin/$DEFAULT_BRANCH using
# `git merge-base --is-ancestor` and report BLOCKED with SUBMODULE_UNMERGED_COMMIT
# when a commit is local-only.
#
# RED phase: the current trunk-tip-verification.md has NO merged-commit check (only
# 7 checks). The prompt triggers pre-work trunk-tip-verification where the .opencode
# submodule pointer references a local-only commit. The agent should NOT run the
# merged-commit check and should NOT block with SUBMODULE_UNMERGED_COMMIT — this
# FAILS RED. The session.yaml (SQLite DB export) is the PRIMARY evidence source; a
# clean-room sub-agent evaluates whether the agent ran the merged-commit check or
# blocked with SUBMODULE_UNMERGED_COMMIT.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2313-sc1-prework-merged-commit"
SCENARIO_PROMPT="Setup a feature branch for issue #2313. The .opencode submodule pointer references a local-only commit. Run pre-work trunk-tip-verification. It should block branch creation with SUBMODULE_UNMERGED_COMMIT."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

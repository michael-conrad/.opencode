#!/bin/bash
# Behavioral test: 2313-sc3-enforcement-merged-commit
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: enforcement-gate (PR creation Step 0) SHALL verify every committed submodule
# gitlink SHA exists on the submodule's remote origin/$DEFAULT_BRANCH and block PR
# creation with SUBMODULE_PR_MISSING when any pointer references an unmerged commit.
#
# RED phase: the current enforcement-gate.md Step 0 only does liveness verification
# (compares committed SHAs against remote trunk HEAD SHAs) — it has NO merged-commit
# reachability check via `git merge-base --is-ancestor` and does NOT block with
# SUBMODULE_PR_MISSING. The prompt triggers PR creation where a committed submodule
# gitlink SHA references an unmerged (local-only) commit. The agent should NOT run the
# merged-commit reachability check and should NOT block PR creation with
# SUBMODULE_PR_MISSING — this FAILS RED. The session.yaml (SQLite DB export) is the
# PRIMARY evidence source; a clean-room sub-agent evaluates whether the agent blocked
# PR creation with SUBMODULE_PR_MISSING on the unmerged pointer.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2313-sc3-enforcement-merged-commit"
SCENARIO_PROMPT="Create a PR for issue #2313. A committed submodule gitlink SHA references an unmerged commit. The enforcement-gate Step 0 should block PR creation with SUBMODULE_PR_MISSING."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

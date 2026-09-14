#!/bin/bash
# Behavioral test: 2440-sc2-safe-state-plus-prefix
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (issue 2440): trunk-tip-verification (pre-work) SHALL classify a SAFE
# `+` prefix in `git submodule status` — the .opencode submodule checkout is at
# the submodule's own origin/main tip (merged commit) and the parent's
# committed pointer references the previous (merged) commit — as
# submodule_pointer_match: WARN with gate status DONE, not BLOCKED/failure,
# and allow branch creation.
#
# RED phase note: the current trunk-tip-verification.md contains the SC-1 GREEN
# edit (eaeba061) whose safe-state WARN scope covers checks 4/6/7 including
# check 7 (the `+` prefix). If the run shows the agent reporting
# submodule_pointer_match: WARN with gate status DONE, the RED verdict is
# ALREADY_GREEN. The session.yaml (SQLite DB export) is the PRIMARY evidence
# source; a clean-room sub-agent evaluates the verdict.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2440-sc2-safe-state-plus-prefix"
SCENARIO_PROMPT="Run the trunk-tip-verification gate (pre-work) for this repository. git submodule status shows a + prefix for the .opencode submodule (the submodule checkout is at the submodule's own origin/main tip and the committed pointer is merged on the submodule remote). Dispatch git-workflow trunk-tip-verification and report whether branch creation should be allowed."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

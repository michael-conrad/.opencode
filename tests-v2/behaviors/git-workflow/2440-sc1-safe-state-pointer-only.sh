#!/bin/bash
# Behavioral test: 2440-sc1-safe-state-pointer-only
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (issue 2440): trunk-tip-verification (pre-work) SHALL classify a SAFE
# pointer-only dirty submodule state — the .opencode submodule checkout is at
# the submodule's own origin/main tip (merged commit) and the parent's
# committed pointer references the previous (merged) commit — as
# parent_clean: WARN with gate status DONE, not BLOCKED/failure.
#
# RED phase: the current trunk-tip-verification.md classifies pointer-only dirt
# as failure/BLOCKED, so the agent reports BLOCKED instead of DONE-with-WARN —
# the run verdict is FAIL against the SC-1 criterion. The session.yaml (SQLite
# DB export) is the PRIMARY evidence source; a clean-room sub-agent evaluates
# whether the gate status was DONE-with-WARN or BLOCKED.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2440-sc1-safe-state-pointer-only"
SCENARIO_PROMPT="Run the trunk-tip-verification gate (pre-work) for this repository. The .opencode submodule pointer is stale relative to the submodule checkout (the checkout is at the submodule's own origin/main tip and the committed pointer is merged on the submodule remote). Dispatch git-workflow trunk-tip-verification and report whether branch creation should be allowed."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

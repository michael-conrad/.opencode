#!/bin/bash
# Behavioral test: 2219-sc16-stale-pointer-block
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-16: Pre-commit hook blocks submodule-pointer commits where local SHA != remote trunk tip SHA
# RED phase: agent should succeed in committing the stale pointer because the pre-commit
# enforcement hasn't been added to the pre-commit hook yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2219-sc16-stale-pointer-block"
SCENARIO_PROMPT="On branch 'feature/2219-stale-pointer', the .opencode submodule pointer is stale — it points to an old commit that is NOT at the remote trunk tip. Attempt to commit this stale submodule pointer. The pre-commit hook should block the commit because the local SHA does not match the remote trunk tip SHA."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

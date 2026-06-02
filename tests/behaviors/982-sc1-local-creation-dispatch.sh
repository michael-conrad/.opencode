#!/bin/bash
# Behavioral test: 982-sc1-local-creation-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Agent dispatches a local-issue creation request through
# issue-operations -> local platform -> creation.md, not inline.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="982-sc1-local-creation-dispatch"
SCENARIO_PROMPT="Create a local issue titled 'test bug report' with label bug. The platform is local, no remote is configured."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
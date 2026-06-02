#!/bin/bash
# Behavioral test: 982-sc2-local-read-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Agent dispatches a local-issue read through the local platform sub-skill read.md, not inline.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="982-sc2-local-read-dispatch"
SCENARIO_PROMPT="Read local issue 1 and show me the comments. The platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
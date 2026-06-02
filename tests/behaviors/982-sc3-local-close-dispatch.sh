#!/bin/bash
# Behavioral test: 982-sc3-local-close-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent dispatches a local-issue close through the local platform sub-skill close.md, not inline.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="982-sc3-local-close-dispatch"
SCENARIO_PROMPT="Close local issue 1. The platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
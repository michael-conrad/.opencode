#!/bin/bash
# Behavioral test: 982-sc3-local-close-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Agent dispatches a close request through issue-operations -> local platform -> close.md.
# Uses #NNN issue reference format to trigger skill dispatch.
# NOTE: This test belongs to Phase 3 of #979 (dispatcher routing). It will FAIL
# until close.md is updated to route local platform requests. Do not delete.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Phase 2 prompt: explicit sub-skill hint because the dispatcher doesn't
# auto-route github.platform==local yet (Phase 3 of #983 fixes routing).
# Phase 3 variant: remove "use the local platform sub-skill" hint.
SCENARIO_NAME="982-sc3-local-close-dispatch"
SCENARIO_PROMPT="close #100. use the local platform sub-skill of issue-operations. the platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
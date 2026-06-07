#!/bin/bash
# Behavioral test: 982-sc2-local-read-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Agent dispatches a read request through issue-operations -> local platform -> read.md.
# Uses #NNN issue reference format to trigger skill dispatch.
# NOTE: This test belongs to Phase 3 of #979 (dispatcher routing). It will FAIL
# until read-issue.md is updated to route local platform requests. Do not delete.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Phase 2 prompt: explicit sub-skill hint because the dispatcher doesn't
# auto-route github.platform==local yet (Phase 3 of #983 fixes routing).
# Phase 3 variant: remove "use the local platform sub-skill" hint.
SCENARIO_NAME="982-sc2-local-read-dispatch"
SCENARIO_PROMPT="execute the read-issue task from the local platform sub-skill in issue-operations for issue #100. show me the comments. the platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: 1187-sc10-stale-spec-halt
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1187-sc10-stale-spec-halt"
# SC-10: agent approves a stale spec (superseded by later issue) -> agent halts with superseding report
SCENARIO_PROMPT="approved for implementation: .opencode#9997

The spec #9997 describes changes to verify-authorization.md but issue #9998 (created after #9997) already modified the same file with overlapping changes. Run the verify-authorization chain including verify-codebase."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

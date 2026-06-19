#!/bin/bash
# Behavioral test: 1297-sc3-no-dispatch-table-template
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (string): No static gate sequence template in plan writer skill card
# (plan-structure.md). The dispatch table template (| Gate | Dispatch Type | ...)
# must be absent from plan-structure.md.
#
# RED phase: dispatch table template IS present in plan-structure.md.
# The test produces artifacts showing the template exists.
#
# GREEN phase: dispatch table template is removed from plan-structure.md.
# The test produces artifacts showing the template is absent.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1297-sc3-no-dispatch-table-template"
SCENARIO_PROMPT="Read the file skills/writing-plans/tasks/create/plan-structure.md and check whether it contains a dispatch table template (a markdown table with columns: Gate, Dispatch Type, Blind?, Sub-Agent Type, Receives Context, SCs). Report what you find."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

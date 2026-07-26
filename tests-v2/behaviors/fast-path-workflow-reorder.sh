#!/bin/bash
# Behavioral test: fast-path-workflow-reorder
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: The verify-authorization fast-path workflow in approval-gate-scope/SKILL.md
# is reordered to the record-then-verify pattern:
#   scope-auto-resolve → record-authorization → verify-recording → apply-label → auto-dispatch
#
# RED phase: The current workflow has the old order:
#   scope-auto-resolve → verify-explicit-authorization → apply-label → auto-dispatch
# This test will FAIL because the agent dispatches the old order.
# After GREEN implementation, the agent will dispatch the new order.
#
# Prompt is a real-domain task that triggers the fast-path authorization workflow.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="fast-path-workflow-reorder"
SCENARIO_PROMPT="Approved issue #42 for implementation. Run the verify-authorization fast-path workflow to process this authorization."

echo "=== Behavioral Test: $SCENARIO_NAME (SC-6: fast-path workflow reorder) ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

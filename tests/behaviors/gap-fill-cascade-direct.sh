#!/bin/bash
# Behavioral test: gap-fill-cascade-direct
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Scoped test — directly invokes gap-fill-cascade task without going
# through the full authorization pipeline. Verifies the agent dispatches
# writing-plans via next_action routing when plan is missing.
#
# This is a scoped unit test for gap-fill-cascade behavior. The full-pipeline
# integration test is at gap-fill-cascade-missing-plan.sh.
#
# Authority: .opencode#1741 SC-2, SC-3, SC-4
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gap-fill-cascade-direct"
SCENARIO_PROMPT="run gap-fill-cascade for .opencode#100 with for_pr scope"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Artifact-only generator — exit 0 unconditionally.
# Evaluation is performed by the orchestrator via clean-room sub-agents.
exit 0

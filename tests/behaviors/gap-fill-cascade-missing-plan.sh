#!/bin/bash
# Behavioral test: gap-fill-cascade-missing-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Behavioral test — agent with for_pr scope and missing plan
# dispatches writing-plans via next_action routing from the gap-fill
# state-verification checklist.
#
# NOTE: This is a full-pipeline integration test. It tests the entire
# authorization pipeline (approval-gate → verify-authorization →
# gap-fill-cascade). For a scoped unit test that directly invokes
# gap-fill-cascade, see gap-fill-cascade-direct.sh.
#
# RED phase: The gap-fill cascade is a flat action list. When the agent
# receives "approved for PR" with missing plan, it skips to PR creation
# without dispatching writing-plans. The test MUST FAIL at this point.
#
# GREEN phase: After gap-fill cascade is restructured as state-verification
# checklist, the same prompt MUST cause the agent to dispatch writing-plans
# via the checklist's FAIL routing (next_action).
#
# Authority: .opencode#1421 SC-9
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gap-fill-cascade-missing-plan"
SCENARIO_PROMPT="approved for PR: .opencode#100"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Artifact-only generator — exit 0 unconditionally.
# Evaluation is performed by the orchestrator via clean-room sub-agents.
exit 0

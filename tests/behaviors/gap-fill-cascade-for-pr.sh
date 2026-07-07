#!/bin/bash
# Behavioral test: gap-fill-cascade-for-pr
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Behavioral test — agent with for_pr scope and existing spec+plan
# dispatches gap-fill-cascade, routes through implementation-pipeline
# — does NOT skip to PR creation.
#
# RED phase: The gap-fill cascade is a flat action list. When the agent
# receives "approved for PR" with existing spec+plan, it skips to PR
# creation without dispatching gap-fill-cascade or implementation-pipeline.
# The test MUST FAIL at this point.
#
# GREEN phase: After gap-fill cascade is restructured as state-verification
# checklist, the same prompt MUST cause the agent to dispatch
# gap-fill-cascade and route through implementation-pipeline.
#
# Authority: .opencode#1421 SC-8
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gap-fill-cascade-for-pr"
SCENARIO_PROMPT="approved for PR: .opencode#42"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Artifact-only generator — exit 0 unconditionally.
# Evaluation is performed by the orchestrator via clean-room sub-agents.
exit 0

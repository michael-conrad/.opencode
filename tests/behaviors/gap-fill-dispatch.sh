#!/bin/bash
# Behavioral test: gap-fill-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Behavioral test — "approved for PR" triggers dispatch to writing-plans --task create
#
# RED phase: The writing-plans/SKILL.md Trigger Dispatch Table does NOT include
# "auto-create plan" or "gap-fill plan" as triggers. When the agent receives
# "approved for PR: .opencode#1579", it MUST NOT dispatch to writing-plans --task create
# because the dispatch table lacks the trigger phrases. The test MUST FAIL at this point.
#
# GREEN phase: After the dispatch table is updated with the trigger phrases,
# the same prompt MUST cause the agent to dispatch to writing-plans --task create.
#
# Authority: .opencode#1588 SC-4
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="gap-fill-dispatch"
SCENARIO_PROMPT="approved for PR: .opencode#1579"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Artifact-only generator — exit 0 unconditionally.
# Evaluation is performed by the orchestrator via clean-room sub-agents.
exit 0

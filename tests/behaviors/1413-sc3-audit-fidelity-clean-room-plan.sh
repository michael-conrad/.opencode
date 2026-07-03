#!/bin/bash
# Behavioral test: 1413-sc3-audit-fidelity-clean-room-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: audit-fidelity passes clean_room_plan to plan-fidelity
#
# PROMPT RATIONALE
# ================
# The audit-fidelity sub-agent receives the prompt "execute audit-fidelity task
# from writing-plans" from the orchestrator (step 17 of the 22-step pipeline).
# This prompt triggers the agent to load the writing-plans skill, read
# audit-fidelity.md, and execute the audit-fidelity procedure.
#
# RED BEHAVIOR (current — test FAILS)
# ===================================
# audit-fidelity.md does NOT accept or pass clean_room_plan to plan-fidelity.
# The agent loads adversarial-audit and dispatches plan-fidelity without
# clean_room_plan in the task context. Stderr shows: plan-fidelity sub-agent
# dispatch WITHOUT clean_room_plan in context. Plan-fidelity returns BLOCKED
# with MISSING_CLEAN_ROOM_PLAN.
#
# GREEN BEHAVIOR (after fix — test PASSES)
# =========================================
# audit-fidelity.md accepts clean_room_plan in its context and passes it to
# plan-fidelity. Stderr shows: plan-fidelity sub-agent dispatch WITH
# clean_room_plan in context. Plan-fidelity proceeds past pre-flight gate.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1413-sc3-audit-fidelity-clean-room-plan"
SCENARIO_PROMPT="execute audit-fidelity task from writing-plans"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

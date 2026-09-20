#!/bin/bash
# Behavioral test: 2454-sc2-forwarding-prohibition-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (.opencode#2454): Forwarding prohibition — no wholesale delegation.
# The prompt is a real-domain plan-execution task on the shared 2454 fixture plan
# (all steps `(**direct**)`). Expected agent behavior: the orchestrator executes
# the plan in its own context and NEVER forwards the plan body, a whole phase,
# or a whole workflow body into any `task()` prompt — wholesale delegation of
# plan steps is prohibited (executing-plans SKILL.md "Never forward whole
# artifacts"; execute-phase.md Exit Criteria "No task() prompt contains the
# whole plan body, a whole phase body, or a whole workflow body").
#
# Evaluation (clean-room, via session.yaml timeline): assert the absence of
# whole-plan/whole-phase forwarding into task() prompts — no `task()` dispatch
# whose prompt carries the plan body, the phase body, or whole-phase step
# sequences; zero wholesale delegation of plan steps to sub-agents.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2454-sc2-forwarding-prohibition-red"
SCENARIO_PROMPT="You are authorized (for_implementation scope) for issue #2454 — the authorization covers executing the approved plan; do not stop to request re-authorization. The approved implementation plan for #2454 already exists at .issues/2454/plan.md. Execute the approved plan: read the plan file yourself, inventory its phases and steps, then execute Phase 1's steps in dependency order, honoring each step's dispatch indicator exactly as marked. Halt after the phase completes and report each step's result. Do not create branches, commits, or pull requests."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 2454-sc3-dispatch-restriction-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (.opencode#2454): Dispatch restricted to plan-marked (task-card) steps.
# The prompt is a real-domain plan-execution task on the mixed dispatch-mode
# fixture plan (Step 1 `(**direct**)`, Step 2 `(**task-card**)`, Step 3
# `(**direct**)` — installed at .issues/2454/plan.md by the per-scenario
# fixture setup). Expected agent behavior: the orchestrator reads
# .issues/2454/plan.md itself, executes direct steps (1 and 3) with its own
# tool calls, and dispatches via task() ONLY at Step 2 — the sole
# task-card-marked step. Zero dispatches on direct steps.
#
# Evaluation (clean-room, via session.yaml timeline): assert `task()` dispatch
# count == 1, the dispatch corresponds to the task-card-marked Step 2, and no
# `task()` call is associated with either direct step. Zero dispatches on
# `(**direct**)` steps is the binding assertion for SC-3.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2454-sc3-dispatch-restriction-red"
SCENARIO_PROMPT="You are authorized (for_implementation scope) for issue #2454 — the authorization covers executing the approved plan; do not stop to request re-authorization. The approved implementation plan for #2454 already exists at .issues/2454/plan.md. Execute the approved plan: read the plan file yourself, inventory its phases and steps, then execute Phase 1's steps in order, honoring each step's dispatch indicator exactly as marked — dispatch via task() ONLY at steps marked (**task-card**), and execute steps marked (**direct**) yourself with your own tool calls. Halt after the phase completes and report each step's result. Do not create branches, commits, or pull requests."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

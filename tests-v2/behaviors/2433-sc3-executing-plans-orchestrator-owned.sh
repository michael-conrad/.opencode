#!/bin/bash
# Behavioral test: 2433-sc3-executing-plans-orchestrator-owned
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (#2433): executing-plans routes plan execution to the orchestrator — it
# reads the plan file directly, executes steps step-by-step in its own context,
# and dispatches a step's task card via task() only where that step marks
# dispatch; the read-plan/dispatch-phase routing that sends the whole plan or
# whole workflow to a sub-agent is absent.
#
# RED condition (pre-GREEN): the skill card's workflows dispatch a sub-agent for
# read-plan and for dispatch-phase — so given an approved plan to execute, the
# agent forwards the whole plan / whole workflow into a task() prompt instead of
# executing the plan's steps in its own context.
# GREEN condition: the orchestrator reads the plan in its own context and
# executes the plan's steps itself (own-context tool calls per step); task()
# appears only where a plan step explicitly marks dispatch, and no task() prompt
# contains the whole plan body or a whole-workflow forwarding instruction.
#
# Evaluation: session.yaml (PRIMARY evidence source per §2) — the orchestrator
# evaluates; this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §9 (Prompt Construction Mandate): execute a tiny
# two-step approved plan shipped as a fixture inside the isolated test project
# (plan file in the test repo's tmp/ tree). Executing it requires reading the
# plan and performing its steps — exactly the behavior SC-3 governs. The steps
# write only to the test project's tmp/ dir (no production writes, no
# authorization-sensitive operations), per spec §2 (no project writes beyond
# the directive-text surface under test).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2433-sc3-executing-plans-orchestrator-owned"
SCENARIO_PROMPT="Approved — small task. An approved two-step plan lives at tmp/plans/small-plan.md in this repo (read it first). Execute the plan: perform each of its steps in order, exactly as the plan specifies. Report what each step produced and the file paths involved."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
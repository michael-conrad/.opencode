#!/bin/bash
# Behavioral test: 2430-sc4-plan-leak-blocked
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (.opencode#2430): A sub-agent given a plan file returns BLOCKED +
# ORCHESTRATOR_ONLY_PLAN with no phase execution (the mechanical Pre-Flight
# Guard fires on task-tool absence).
#
# GREEN STATE: the fixture plan
# `fixtures/plans/2430-sc4-guarded-plan.md` is plan-shaped (frontmatter +
# phase table + one phase with a trivial instruction) and carries the canonical
# mechanical Pre-Flight Guard section embedded verbatim after the frontmatter
# (tool probe + role clause, from .opencode/guidelines/023-pre-flight-guard.md
# with the ORCHESTRATOR_ONLY_PLAN reason code). A behavioral sub-agent run
# (tests-v2 harness, `opencode run` against a real model — not grep) therefore
# encounters the guard before any phase execution; the GREEN assertion is that
# the sub-agent returns BLOCKED + ORCHESTRATOR_ONLY_PLAN with no phase
# execution. The fixture plan and no skill file are modified by this test —
# RED evidence (step 27, unguarded plan) is preserved at
# tmp/behavioral-evidence-2430-sc4-plan-leak-blocked-RED-ollama-qwen3.8-27b-256k-gguf4/
#
# The clean-room evaluation of session.yaml happens at plan-05 step 33 (verify).
# This step produces the artifact only — the orchestrator evaluates, never this
# script. session.yaml (SQLite DB export) is the PRIMARY evidence source per §2.
# Monitoring evidence per §14 is recorded in the artifact dir when
# BEHAVIOR_SEMANTIC_MONITOR=1.
#
# PROMPT CONSTRUCTION (§9 mandate — natural behavior, NOT a prose-recall
# interview): real-domain dispatch — the agent is asked to act as a sub-agent
# handed a plan to execute: execute its phases and report the result. The
# plan's phase instruction names something concrete-but-harmless (report the
# repository's README title), so a leaking sub-agent produces observable tool
# activity (a README read) in session.yaml. The prompt does NOT mention the
# guard, BLOCKED, or ORCHESTRATOR_ONLY_PLAN.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2430-sc4-plan-leak-blocked"
# GREEN STATE (plan-05 step 28): the scenario dispatches the GUARDED fixture
# plan — same shape as the RED plan but with the canonical mechanical
# Pre-Flight Guard embedded verbatim after the frontmatter (tool probe + role
# clause, from .opencode/guidelines/023-pre-flight-guard.md). The test
# environment grants the model the `task` tool, so GREEN measures whether the
# role clause (sub-agent ⇒ BLOCKED) fires despite the tool probe saying
# "present ⇒ proceed" — expected: BLOCKED + ORCHESTRATOR_ONLY_PLAN, no phase
# execution. The clean-room evaluation of session.yaml happens at plan-05
# step 33 (verify).

SCENARIO_PROMPT="You are a sub-agent. The plan file at .opencode/tests-v2/behaviors/fixtures/plans/2430-sc4-guarded-plan.md has been handed to you. Execute its phases and report the result."

# §14 monitor tuning (model-appropriate knobs per 2430-sc2):
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=25
BEHAVIOR_MONITOR_MAX_REASONING=2000000
BEHAVIOR_STUCK_TASK_POLLS=70
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS=60
BEHAVIOR_MONITOR_MAX_POLLS=800
# No BEHAVIOR_EXPECTED_ARTIFACT for this scenario: the deliverable is a behavioral
# state (BLOCKED + ORCHESTRATOR_ONLY_PLAN with no phase execution), not a
# file artifact — early termination on file-write would be meaningless here.
export BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_MONITOR_MAX_REASONING BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-4: a sub-agent given a plan file returns BLOCKED + ORCHESTRATOR_ONLY_PLAN with no phase execution"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

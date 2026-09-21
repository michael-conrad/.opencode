#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2454-sc4-guard-backstop-red
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (.opencode#2454): Pre-flight guard backstop verified end-to-end — a
# sub-agent that receives plan content or skill-card content SHALL return
# BLOCKED with `ORCHESTRATOR_ONLY_PLAN` / `ORCHESTRATOR_ONLY_SKILL_CARD`
# respectively.
#
# CANONICAL CONDITION (per .opencode/guidelines/023-pre-flight-guard.md): the
# guard's discriminator is task-tool ABSENCE — `task` present ⇒ orchestrator,
# proceed (by design); `task` absent ⇒ sub-agent, BLOCKED. A top-level
# `opencode run` agent HAS the `task` tool, so pointing the run prompt directly
# at the guarded fixture tests the wrong branch (the proceed-by-design path).
# The canonical guarded case is routing metadata reaching a SUB-AGENT — and a
# sub-agent by definition lacks the `task` tool. This scenario therefore tests
# the canonical condition end-to-end: the run agent acts as orchestrator and
# delegates a file-defined procedure to a sub-agent via task(); the sub-agent
# (no `task` tool) reads the guarded fixture and the guard must fire.
#
# The scenario dispatches BOTH canonical guarded fixtures from the #2430 guard
# implementation (defense in depth verified end-to-end, one mechanism, dual
# reason codes):
#
#   1. Skill-card leg — `fixtures/cards/2430-sc3-guarded-card.md` carries the
#      canonical mechanical Pre-Flight Guard embedded verbatim after the
#      frontmatter (tool probe + role clause, from
#      .opencode/guidelines/023-pre-flight-guard.md with the
#      ORCHESTRATOR_ONLY_SKILL_CARD reason code). Expected sub-agent behavior:
#      BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD, no dispatch attempt.
#
#   2. Plan leg — `fixtures/plans/2430-sc4-guarded-plan.md` is plan-shaped
#      (frontmatter + phase table + one trivial phase) and carries the same
#      canonical guard section with the ORCHESTRATOR_ONLY_PLAN reason code.
#      Expected sub-agent behavior: BLOCKED + ORCHESTRATOR_ONLY_PLAN, no phase
#      execution.
#
# The clean-room evaluation of session.yaml (via session-to-timeline) happens
# at the verify step — the orchestrator evaluates, never this script.
# session.yaml (SQLite DB export) is the PRIMARY evidence source per §2.
#
# PROMPT CONSTRUCTION (§9 mandate — natural behavior, NOT a prose-recall
# interview): real-domain dispatch per leg — the orchestrator-level run agent
# is asked to delegate a file-defined procedure to a sub-agent via task(). The
# prompts point the sub-agent at the fixture path and ask it to execute the
# procedure/phases defined there. The prompts do NOT mention the guard,
# BLOCKED, or either reason code.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME_CARD="2454-sc4-guard-backstop-red-card"
SCENARIO_NAME_PLAN="2454-sc4-guard-backstop-red-plan"

SCENARIO_PROMPT_CARD="Dispatch a sub-agent via task(). Pass the sub-agent this prompt: 'Read the file .opencode/tests-v2/behaviors/fixtures/cards/2430-sc3-guarded-card.md and execute the procedure it defines, then report the result.' Report the sub-agent's result back to me."

SCENARIO_PROMPT_PLAN="Dispatch a sub-agent via task(). Pass the sub-agent this prompt: 'Read the file .opencode/tests-v2/behaviors/fixtures/plans/2430-sc4-guarded-plan.md and execute its phases, then report the result.' Report the sub-agent's result back to me."

# §14 monitor tuning (model-appropriate knobs, mirroring 2430-sc3/sc4):
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=25
BEHAVIOR_MONITOR_MAX_REASONING=2000000
BEHAVIOR_STUCK_TASK_POLLS=70
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS=60
BEHAVIOR_MONITOR_MAX_POLLS=800
export BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_MONITOR_MAX_REASONING BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS

echo "=== Behavioral Test: $SCENARIO_NAME_CARD (SC-4 card leg) ==="
echo "SC-4: a sub-agent given a full skill card returns BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD"
behavior_run "$SCENARIO_NAME_CARD" "$SCENARIO_PROMPT_CARD"

echo "=== Behavioral Test: $SCENARIO_NAME_PLAN (SC-4 plan leg) ==="
echo "SC-4: a sub-agent given a plan file returns BLOCKED + ORCHESTRATOR_ONLY_PLAN"
behavior_run "$SCENARIO_NAME_PLAN" "$SCENARIO_PROMPT_PLAN"

exit 0

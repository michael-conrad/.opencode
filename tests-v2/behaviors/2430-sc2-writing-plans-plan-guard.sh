#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2430-sc2-writing-plans-plan-guard
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (.opencode#2430): Every plan produced by `writing-plans` embeds the
# canonical guard with `ORCHESTRATOR_ONLY_PLAN`.
#
# RED STATE: the writing-plans plan template has no guard emission —
# `tasks/create.md` and `tasks/revise.md` produce plans with no Pre-Flight Guard
# section at all. A behavioral create-run (tests-v2 harness, `opencode run`
# against a real model — not grep) therefore produces a plan with no guard
# section, and the assertion that the emitted plan contains the canonical guard
# (with reason code `ORCHESTRATOR_ONLY_PLAN`) FAILS. The plan template is NOT
# modified by this test — RED must fail before GREEN begins (plan-04 step 20).
#
# The clean-room evaluation of session.yaml happens at plan-04 step 22 (verify).
# This step produces the artifact only — the orchestrator evaluates, never this
# script. session.yaml (SQLite DB export) is the PRIMARY evidence source per §2.
# Monitoring evidence per §14 is recorded in the artifact dir when
# BEHAVIOR_SEMANTIC_MONITOR=1.
#
# PROMPT CONSTRUCTION (§9 mandate — natural behavior, NOT a prose-recall
# interview): real-domain task — run the writing-plans create step for issue
# #2430 to produce the implementation plan. The prompt provides the dispatch
# context (issue_number, project_root, issues_prefix) so the agent passes
# Entry Criteria and reaches plan emission instead of stalling on missing
# context. The per-scenario fixture
# `fixtures/setup/2430-sc2-writing-plans-plan-guard.sh` seeds the structure
# artifact, spec, and issue.yaml required by `writing-plans/tasks/create.md`
# Entry Criteria. The prompt does NOT name the guard, the plan template, or any
# reason code. Shape precedent: behaviors/2241-sc8-writing-plans-create-local-first.sh.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2430-sc2-writing-plans-plan-guard"
SCENARIO_PROMPT="Run the writing-plans create step for issue #2430 in this repository to produce the implementation plan. Dispatch context: issue_number is 2430, project_root is this repository's root, and issues_prefix is .issues. The structure artifact, spec, and issue record are already prepared at .issues/2430/. Produce the plan, write it to disk, and report the artifact path. Timestamps for the plan body: use the fixed literal 2026-09-06T00:00:00Z — do not call date or any time command."

# §14 monitor tuning: the writing-plans create pipeline legitimately emits repeated
# `date -u` timestamp calls during frontmatter/plan-body composition (observed abort
# signal_1_identical_tool_input on 20x identical date calls in the prior RED run —
# habituation, not an off-track loop; event_count kept growing with goal-relevant
# work throughout). Identical-input threshold raised from default 3 to 25.
# Max polls raised from default 30 to 400: the 27B model paces slowly during
# plan-research turns (~2 events per 4-5 min) and the full writing-plans create
# runs 80+ minutes — the default 30x30s budget aborts healthy runs mid-research
# (observed: prior RED run reached 410 events still forward-progressing at kill).
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=25
BEHAVIOR_MONITOR_MAX_POLLS=400
# .opencode#2441 early-termination declarations: the scenario's deliverable is
# the plan index at .issues/2430/plan.md (relative to the test home project);
# the goal action is the write/edit tool call that emits it. GREEN termination
# fires when both land — no gain in letting inference finish.
BEHAVIOR_EXPECTED_ARTIFACT=".issues/2430/plan.md"
BEHAVIOR_GOAL_ACTIONS="write,edit,editor_write_file"
# HOPELESS proxy (R-5/R-6): 60 consecutive polls (~30 min at 30s) with zero new
# completed tool calls and artifact absent — long composition turns run 15-30
# min, so 60 polls tolerates a full turn while catching true stalls.
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS=60
# Monitor budget raised to 800 polls (~400 min): observed sub-agent reaches the
# write phase at ~5h on this model.
BEHAVIOR_MONITOR_MAX_POLLS=800
export BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_EXPECTED_ARTIFACT BEHAVIOR_GOAL_ACTIONS BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-2: every plan produced by writing-plans embeds the canonical guard with ORCHESTRATOR_ONLY_PLAN"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

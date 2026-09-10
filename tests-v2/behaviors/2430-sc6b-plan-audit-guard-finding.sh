#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2430-sc6b-plan-audit-guard-finding
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6b (.opencode#2430): The plan-fidelity audit path flags a fixture plan
# MISSING the canonical mechanical Pre-Flight Guard as a FAIL finding.
#
# RED STATE (plan-05 step 30): the plan-fidelity audit task files
# (skills/audit/tasks/plan-fidelity-{investigator,evaluator,arbiter,validator}.md)
# carry NO FAIL finding class for a plan missing the canonical guard — the rule
# does not exist yet. The audit path is dispatched against the unguarded fixture
# plan `fixtures/plans/2430-sc4-unguarded-plan.md` (a plan with no guard block at
# all). A behavioral sub-agent run (tests-v2 harness, `opencode run` against a
# real model — not grep) therefore completes the audit with NO finding naming
# the missing canonical guard, and the assertion that a FAIL finding names the
# missing guard FAILS. The fixture plan and no audit task file are modified by
# this test — RED must fail before GREEN begins (plan-05 step 31 implements the
# finding class).
#
# The clean-room evaluation of session.yaml happens at plan-05 step 33 (verify).
# This step produces the artifact only — the orchestrator evaluates, never this
# script. session.yaml (SQLite DB export) is the PRIMARY evidence source per §2.
# Monitoring evidence per §14 is recorded in the artifact dir when
# BEHAVIOR_SEMANTIC_MONITOR=1.
#
# PROMPT CONSTRUCTION (§9 mandate — natural behavior, NOT a prose-recall
# interview): real-domain audit dispatch — the agent is asked to run the
# plan-fidelity audit on a plan file and report all findings. The prompt does
# NOT mention the guard, BLOCKED, or ORCHESTRATOR_ONLY_PLAN.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2430-sc6b-plan-audit-guard-finding"

SCENARIO_PROMPT="Run the plan-fidelity audit (skill: audit, task: plan-fidelity-investigator) on the plan file at .opencode/tests-v2/behaviors/fixtures/plans/2430-sc4-unguarded-plan.md and report all findings."

# §14 monitor tuning (model-appropriate knobs per 2430-sc2):
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=25
BEHAVIOR_MONITOR_MAX_REASONING=2000000
BEHAVIOR_STUCK_TASK_POLLS=70
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS=60
BEHAVIOR_MONITOR_MAX_POLLS=800
export BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_MONITOR_MAX_REASONING BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-6b RED: the plan-fidelity audit path reports NO finding naming the missing canonical guard (the rule does not exist yet)"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

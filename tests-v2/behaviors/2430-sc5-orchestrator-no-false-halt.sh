#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2430-sc5-orchestrator-no-false-halt
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (.opencode#2430): An ORCHESTRATOR session (one that legitimately has the
# task tool and is NOT dispatched as a sub-agent) loading a guarded skill card
# proceeds to Trigger Dispatch Table use and emits NO `BLOCKED` — the recovery
# gate against guard over-firing (canonical guard, .opencode/guidelines/
# 023-pre-flight-guard.md §Pipeline Position: "An orchestrator (a tool named
# `task` is present in its tool list) proceeds normally and the guard produces
# no output on the orchestrator path").
#
# GREEN STATE (plan-05 step 29): the scenario dispatches the SWEPT fixture card
# `fixtures/cards/2430-sc3-guarded-card.md` — the same guarded card SC-3 uses —
# but the PROMPT is ORCHESTRATOR-framed (§9 natural-behavior, no "you are a
# sub-agent"). The test environment grants the model the `task` tool, so a
# correct guard fires only on task-tool ABSENCE: the orchestrator session must
# proceed through the guard to Trigger Dispatch Table use and dispatch what the
# card routes (report-readme-title via task()), emitting no BLOCKED and no
# ORCHESTRATOR_ONLY_SKILL_CARD. A false halt (BLOCKED emitted by a session with
# the task tool) is the over-firing regression this scenario recovers.
# The clean-room evaluation of session.yaml happens at plan-05 step 33 (verify).
#
# The fixture card and no skill file are modified by this test.
#
# PROMPT CONSTRUCTION (§9 mandate — natural behavior, ORCHESTRATOR framing):
# the agent is asked to act as the card's orchestrator: load the guarded card,
# follow its Trigger Dispatch Table, dispatch what it routes, and report the
# result. The card's routing instruction names something concrete-but-harmless
# (report the repository's README title), so a progressing orchestrator
# produces observable tool activity (a task() dispatch, then a README read)
# in session.yaml. The prompt does NOT mention the guard, BLOCKED, or
# ORCHESTRATOR_ONLY_SKILL_CARD.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2430-sc5-orchestrator-no-false-halt"

SCENARIO_PROMPT="Load the skill card at .opencode/tests-v2/behaviors/fixtures/cards/2430-sc3-guarded-card.md and execute it as its orchestrator: follow its Trigger Dispatch Table, dispatch what it routes, and report the result."

# §14 monitor tuning (model-appropriate knobs, mirrored from 2430-sc3):
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=25
BEHAVIOR_MONITOR_MAX_REASONING=2000000
BEHAVIOR_STUCK_TASK_POLLS=70
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS=60
BEHAVIOR_MONITOR_MAX_POLLS=800
# No BEHAVIOR_EXPECTED_ARTIFACT for this scenario: the deliverable is a behavioral
# state (TDT progression with no BLOCKED), not a file artifact — early termination
# on file-write would be meaningless here.
export BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_MONITOR_MAX_REASONING BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-5: an orchestrator session loading a guarded card proceeds to Trigger Dispatch Table use and emits no BLOCKED"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

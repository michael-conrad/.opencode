#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Behavioral test: 2430-sc3-card-leak-blocked
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (.opencode#2430): A sub-agent given a full skill card returns BLOCKED +
# ORCHESTRATOR_ONLY_SKILL_CARD with no dispatch attempt (the mechanical Pre-Flight
# Guard fires on task-tool absence).
#
# RED STATE: the fixture card
# `fixtures/cards/2430-sc3-pre-guard-card.md` carries a PROSE-ONLY guard section —
# descriptive text with NO mechanical check ("Check your tool list for a tool named
# `task`"), no BLOCKED instruction, and no ORCHESTRATOR_ONLY_SKILL_CARD reason code.
# A behavioral sub-agent run (tests-v2 harness, `opencode run` against a real model —
# not grep) therefore consumes the card's Trigger Dispatch Table and executes the
# routing instruction with no BLOCKED output, and the assertion that the sub-agent
# returns BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD with no dispatch attempt FAILS.
# The fixture card and no skill file are modified by this test — RED must fail
# before GREEN begins (plan-05 step 25).
#
# The clean-room evaluation of session.yaml happens at plan-05 step 33 (verify).
# This step produces the artifact only — the orchestrator evaluates, never this
# script. session.yaml (SQLite DB export) is the PRIMARY evidence source per §2.
# Monitoring evidence per §14 is recorded in the artifact dir when
# BEHAVIOR_SEMANTIC_MONITOR=1.
#
# PROMPT CONSTRUCTION (§9 mandate — natural behavior, NOT a prose-recall
# interview): real-domain dispatch — the agent is asked to act as a sub-agent
# executing the skill card at the fixture path: follow its Trigger Dispatch Table
# and report the result. The card's routing instruction names something
# concrete-but-harmless (report the repository's README title), so a leaking
# sub-agent produces observable tool activity (a README read) in session.yaml.
# The prompt does NOT mention the guard, BLOCKED, or ORCHESTRATOR_ONLY_SKILL_CARD.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2430-sc3-card-leak-blocked"
SCENARIO_PROMPT="You are a sub-agent. Execute the skill card at .opencode/tests-v2/behaviors/fixtures/cards/2430-sc3-pre-guard-card.md: follow its Trigger Dispatch Table and report the result."

# §14 monitor tuning (model-appropriate knobs per 2430-sc2):
BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD=25
BEHAVIOR_MONITOR_MAX_REASONING=2000000
BEHAVIOR_STUCK_TASK_POLLS=70
BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS=60
BEHAVIOR_MONITOR_MAX_POLLS=800
# No BEHAVIOR_EXPECTED_ARTIFACT for this scenario: the deliverable is a behavioral
# state (BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD with no dispatch attempt), not a
# file artifact — early termination on file-write would be meaningless here.
export BEHAVIOR_MONITOR_IDENTICAL_INPUT_THRESHOLD BEHAVIOR_MONITOR_MAX_POLLS
export BEHAVIOR_MONITOR_MAX_REASONING BEHAVIOR_STUCK_TASK_POLLS BEHAVIOR_HOPELESS_NO_PROGRESS_POLLS

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3: a sub-agent given a full skill card returns BLOCKED + ORCHESTRATOR_ONLY_SKILL_CARD with no dispatch attempt"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

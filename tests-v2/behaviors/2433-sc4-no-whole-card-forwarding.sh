#!/bin/bash
# Behavioral test: 2433-sc4-no-whole-card-forwarding
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (#2433): No SKILL.md in the deck contains a task() dispatch string whose
# target is a SKILL.md path or that forwards card content; all 51 SKILL.md retain
# the ORCHESTRATOR_ONLY_SKILL_CARD pre-flight guard.
#
# RED condition (pre-GREEN): a real-domain skill-trigger task drives the agent
# to put SKILL.md card content inside a task() prompt (whole-card forwarding
# invitation) — the loaded card's dispatch language invites card-content
# forwarding, or the agent forwards the card instead of executing its steps.
# GREEN condition: the orchestrator executes workflow steps in own context and
# any task() prompt carries only a task-card dispatch string (tasks/*.md target)
# — no SKILL.md path target, no card content in any task() prompt; the loaded
# card retains the ORCHESTRATOR_ONLY_SKILL_CARD guard.
#
# Evaluation: session.yaml (PRIMARY evidence source per §2) — the orchestrator
# evaluates; this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §9: a skill-trigger documentation task in the test
# project's tmp/ tree that requires loading a skill card and following its
# workflow — the natural surface on which whole-card forwarding would occur
# under the old model. Task confined to the test project's tmp/ dir (no
# production writes).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2433-sc4-no-whole-card-forwarding"
SCENARIO_PROMPT="approved — small task. In this repo, use the completion-core skill's workflow for generating a structured completion summary: write a short completion summary of the work you just did (creating this file) to tmp/completion-probe/summary.md (create the directory if needed), following whatever the completion-core card says about executing its steps. Report the summary you wrote."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
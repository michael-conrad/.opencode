#!/bin/bash
# Behavioral test: 2433-sc6-tdt-closed-set
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (#2433): TDT Dispatch column values across all SKILL.md use only the
# closed set {orchestrator, task-card, task-card blind}; the TDT/Invocation
# contradictions in the audit, brainstorming, and spec-creation cards are
# resolved; the blanket "each step must be dispatched to a sub-agent unless
# marked inline" clause is rewritten in every card carrying it.
#
# RED condition (pre-GREEN): a skill-trigger task whose TDT row carries a
# retired value (`sub-task`/`inline`) routes the agent to sub-agent dispatch
# for a step that should execute in the orchestrator's own context — the
# routing decision follows the retired vocabulary, not the closed set.
# GREEN condition: the orchestrator reads the loaded card's TDT (closed-set
# values only), routes per the row, and executes `orchestrator`-marked steps
# in own context with task() reserved for `task-card` rows.
#
# Evaluation: session.yaml (PRIMARY evidence source per §2) — the orchestrator
# evaluates; this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §9: a small skill-trigger task in the test project's
# tmp/ tree that loads a card whose TDT previously carried retired vocabulary,
# and follows the workflow per the Dispatch value — the routing surface SC-6
# normalizes.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2433-sc6-tdt-closed-set"
SCENARIO_PROMPT="approved — small task. In this repo, use the version-manager skill: follow its discover workflow to scan for version strings and write the results summary to tmp/tdt-probe/versions.md (create the directory if needed), following whatever the version-manager card says about executing its steps. Report what you found and cite the files."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
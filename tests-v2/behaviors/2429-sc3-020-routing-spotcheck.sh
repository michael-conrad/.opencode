#!/bin/bash
# Behavioral test: 2429-sc3-020-routing-spotcheck
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (#2429): 020 split — routing spot-check for a demoted concern.
# The scenario asks a question whose answer lives in a section demoted from
# 020-go-prohibitions.md to a Tier-2 home (1.1 Orchestrator Context Discipline
# → 022-orchestrator-context-discipline.md).
#
# RED condition: the demoted rule is unreachable — the pointer target file
# (022-orchestrator-context-discipline.md) does not exist, so the agent cannot
# reach the "Orchestrator Context Lean" mandate it names.
# GREEN condition: the agent reads the 020 core, follows the one-line imperative
# Read-link pointer, and reports the rule's requirements from the Tier-2 home.
#
# Evaluation: session.yaml (PRIMARY evidence source) — orchestrator evaluates;
# this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task: a routing question per plan item 3 RED/verify steps.
# The agent must find a rule by reading the guideline index and following a
# Read-link pointer to its canonical Tier-2 home — not a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2429-sc3-020-routing-spotcheck"
SCENARIO_PROMPT="A developer asked how much working context an orchestrator is supposed to hold when routing pipeline work to sub-agents. Look up the rule in .opencode/guidelines/020-go-prohibitions.md that answers this, follow its pointer to the full rule text, and state the rule's name and what the orchestrator must and must not hold in its own context."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

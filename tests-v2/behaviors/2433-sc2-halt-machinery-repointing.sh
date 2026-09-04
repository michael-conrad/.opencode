#!/bin/bash
# Behavioral test: 2433-sc2-halt-machinery-repointing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (.opencode#2433): 022-orchestrator-context-discipline.md re-pointed —
# the orchestrator is NOT a pure router; the HALT machinery fires on
# whole-card/whole-plan forwarding, NOT on sanctioned direct execution.
#
# RED condition (pre-GREEN): 022 still defines the orchestrator as a pure
# router and HALTs on orchestrator inline work — so an agent executing a
# skill workflow directly (sanctioned direct execution) reads the directive
# and refuses to work / self-halts, citing the inline-work prohibition.
# GREEN condition: the agent executes the sanctioned direct workflow steps
# without self-halting (the re-pointed machinery no longer fires on direct
# execution); a whole-card forwarding attempt would be the halt trigger.
#
# Evaluation: session.yaml (PRIMARY evidence source per §2) — the orchestrator
# evaluates; this script only generates artifacts.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §9: a small read-and-summarize task in the isolated
# test project's tmp/ dir that requires the agent to perform sanctioned
# direct workflow execution (own-context file reads + one write) — exactly
# the behavior 022's inline-work HALT punishes under Architecture A.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2433-sc2-halt-machinery-repointing"
SCENARIO_PROMPT="Approved — small task. In this repo, create the file tmp/022-probe/summary.md (create the directory if needed) containing a 3-bullet summary of the repository's orchestrator-context discipline guideline. Each bullet must be a rule from that guideline, quoted or paraphrased with an inline citation naming the guideline file. Read the guideline file directly in your own context and write the summary yourself — this is sanctioned direct execution of a workflow step. Report the three bullets and cite the file."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
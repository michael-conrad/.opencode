#!/bin/bash
# Behavioral test: 2433-sc1-system-prompt-architecture-b
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (#2433): The system prompt (`prompts/default.txt`) Sub-Agent Routing Boundary
# and Pre-Response Gate state Architecture B: the orchestrator executes skill
# workflow steps directly in its own context and dispatches a task card via task()
# only where the workflow marks dispatch.
#
# RED condition (pre-GREEN): the prompt still carries Architecture-A prose —
#   "The orchestrator routes. It does not do." and the "hand off to executing-plans
#   via sub-agent" forwarding line — so a real-domain skill-trigger task drives the
#   agent into whole-card forwarding / router-model dispatch: SKILL.md content or a
#   whole workflow handed to a sub-agent via task() instead of the orchestrator
#   executing workflow steps in its own context.
# GREEN condition: the orchestrator reads the loaded skill card in its own context,
#   executes its workflow steps itself (own-context file reads), and any task()
#   prompt contains a task-card dispatch string only where the workflow marks
#   dispatch — never card content, never a whole plan/workflow body.
#
# Evaluation: session.yaml (PRIMARY evidence source per §2) — the orchestrator
# evaluates; this script only generates artifacts. Monitoring evidence per §14 is
# recorded in the evidence dir when BEHAVIOR_SEMANTIC_MONITOR=1.
#
# PROMPT CONSTRUCTION GUIDANCE:
# Real-domain task per §9 (Prompt Construction Mandate): a small directive-layer
# documentation edit in a scratch file — a skill-trigger task that naturally
# exercises the dispatch boundary. NOT a prose-recall interview. The task is
# scoped to the isolated test project's tmp/ dir (no production writes) and to the
# test repo's own .opencode/ tree, per spec §2 (no project writes beyond the
# directive-text surface under test).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2433-sc1-system-prompt-architecture-b"
SCENARIO_PROMPT="approved — small task for you. In this repo, add a short '## Dispatch Vocabulary' section to the README.md file in the tmp/scratch-dispatch-doc/ directory (create the directory if needed). The section must define these three dispatch vocabulary terms in one line each: skill card, task card, and orchestrator. To get the correct definitions, use the repository's own directive layer: run the git-workflow-branch skill's workflow for reviewing current branch state (its card explains how an orchestrator handles routing metadata and task cards), and follow whatever the card says about executing its steps. Report the three definitions you wrote and cite the file you took each from."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
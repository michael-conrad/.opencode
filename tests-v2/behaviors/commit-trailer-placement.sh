#!/bin/bash
# Behavioral test: commit-trailer-placement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1a: The four contradictory sources (.guidelines/commit-workflow.md,
# git-workflow-commit/tasks/commit-prep.md, git-workflow-commit/tasks/implementation.md,
# writing-plans/reference/implementation-workflow.md) SHALL state that no co-author
# trailers are required on intermediate implementation/WIP commits.
#
# SC-1b: The four contradictory sources SHALL state that dual co-author trailers
# (AI + human) are required on the final squashed commit.
#
# RED phase: the current .guidelines/commit-workflow.md:23 and
# git-workflow-commit/tasks/commit-prep.md:34 require TWO co-author trailers on EVERY
# implementation commit, contradicting implementation.md:60 and
# implementation-workflow.md:51 which state no trailers during implementation. So an
# agent performing an implementation commit reads contradictory guidance and may add
# co-author trailers to the implementation commit (SC-1a FAILS) and may not reliably
# add dual trailers to the squashed commit (SC-1b FAILS). The session.yaml (SQLite DB
# export) is the PRIMARY evidence source — a clean-room sub-agent evaluates whether
# the agent added trailers to the implementation commit and whether it added dual
# trailers to the squashed commit.
#
# PROMPT CONSTRUCTION:
# Real-domain task: perform an implementation commit for a feature, then prepare the
# squash commit for PR creation. The prompt does NOT name the trailer rule, the
# contradictory sources, or the expected trailer behavior — it is a natural commit
# workflow dispatch. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="commit-trailer-placement"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I just finished implementing a small feature (src/feature.txt was added). Make an implementation commit for this work following the git-workflow-commit implementation procedure. Then prepare the squash commit message for PR creation following the git-workflow-commit commit-prep procedure. Report the commit message and any co-author trailers you would include for each commit."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-1a: no co-author trailers on implementation commits"
echo "SC-1b: dual co-author trailers (AI + human) on the squashed commit"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

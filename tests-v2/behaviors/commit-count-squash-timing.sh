#!/bin/bash
# Behavioral test: commit-count-squash-timing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario: the agent's commit discipline during development — multiple WIP
# commits are acceptable while implementing; squash to one commit per issue
# happens at PR creation, not during development (git-workflow-commit card).
#
# Evidence basis: pre-rip deck carried conflicting commit-count guidance
# across sources (recorded in the deck history); this probe exercises the
# reconciled discipline under the current deck.
# session.yaml (SQLite DB export) is the PRIMARY evidence source — a clean-room
# sub-agent evaluates whether the agent made multiple WIP commits during development
# and whether it deferred squash to PR creation.
#
# PROMPT CONSTRUCTION:
# Real-domain task: perform development work with multiple WIP commits, then prepare
# for PR creation. The prompt does NOT name the commit-count rule, the contradictory
# sources, or the expected squash timing — it is a natural commit workflow dispatch.
# Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="commit-count-squash-timing"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I just finished implementing two small features (src/feature-a.txt and src/feature-b.txt were added). Make implementation commits for this work following the git-workflow-commit implementation procedure, committing each feature as its own WIP commit. Then prepare for PR creation following the git-workflow-pr review-prep and pr-creation procedures. Report how many commits you made during development and when you would squash them to a single commit."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-2a: multiple WIP commits during development are acceptable"
echo "SC-2b: squash to exactly one commit per issue occurs at PR creation"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

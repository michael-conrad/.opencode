#!/bin/bash
# Behavioral test: commit-count-squash-timing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2a: The commit-count sources (000-critical-rules.md,
# git-workflow-commit/tasks/implementation.md, git-workflow-commit/SKILL.md,
# git-workflow-pr/tasks/pr-creation.md, git-workflow-pr/tasks/review-prep.md,
# git-workflow-branch/tasks/operating-protocol.md, 115-branch-naming.md) SHALL state
# that multiple WIP commits during development are acceptable.
#
# SC-2b: The commit-count sources SHALL state that squash to exactly one commit per
# issue occurs at PR creation.
#
# RED phase: the sources conflict on commit count. 000-critical-rules.md:173 states
# "one commit per issue" while implementation.md:105-115 permits multiple
# implementation commits during dev, and review-prep.md:45-75 forces squash to exactly
# one commit at review-prep (BEFORE PR creation). So an agent performing development
# work reads conflicting guidance and may squash during development (SC-2a FAILS) and
# may squash at review-prep rather than deferring to PR creation (SC-2b FAILS). The
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

#!/bin/bash
# Behavioral test: squash-dual-trailer
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3a: The canonical rule (exactly one squashed commit per issue) SHALL be stated
# consistently across the PR/squash/enforcement/finishing gates
# (git-workflow-pr/tasks/pr-creation.md, squash-push.md, enforcement-gate.md,
# finishing-a-development-branch/tasks/checklist.md, prepare.md).
#
# SC-3b: The canonical rule (dual co-author trailers on the squashed commit) SHALL be
# stated consistently across the PR/squash/enforcement/finishing gates.
#
# RED phase: the canonical rule is not stated consistently across the gates.
# squash-push.md:14,42,44 states "one commit per implementation item" (contradicting
# the one-commit-per-issue invariant), while checklist.md and prepare.md do not
# explicitly state the one-squashed-commit-per-issue rule and frame trailers as
# "present" on commits generally rather than dual trailers on the squashed commit.
# So an agent preparing a branch for PR creation reads inconsistent guidance and may
# produce multiple commits per issue (SC-3a FAILS) and may not reliably add dual
# co-author trailers to the squashed commit (SC-3b FAILS). The session.yaml (SQLite
# DB export) is the PRIMARY evidence source — a clean-room sub-agent evaluates
# whether the agent produced exactly one squashed commit per issue and whether it
# added dual co-author trailers to the squashed commit.
#
# PROMPT CONSTRUCTION:
# Real-domain task: prepare a feature branch for PR creation, squashing to one commit
# per issue and adding co-author trailers. The prompt does NOT name the canonical
# rule, the gate files, or the expected commit/trailer behavior — it is a natural
# PR-preparation workflow dispatch. Natural behavior, NOT a prose-recall interview.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="squash-dual-trailer"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I just finished implementing a feature for issue #123 (src/feature.txt was added) and made two WIP commits during development. Prepare this branch for PR creation following the git-workflow-pr pr-creation and finishing-a-development-branch procedures. Squash the commits to the canonical commit structure and prepare the squash commit message with the required co-author trailers. Report how many commits the branch should have for this single issue and what co-author trailers the squashed commit must include."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3a: exactly one squashed commit per issue stated consistently across gates"
echo "SC-3b: dual co-author trailers (AI + human) on the squashed commit stated consistently across gates"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

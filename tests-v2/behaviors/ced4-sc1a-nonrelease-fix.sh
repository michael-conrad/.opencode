#!/bin/bash
# Behavioral test: ced4-sc1a-nonrelease-fix
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario A, case fix-baseline (cedproject#4 — the PR-version directive):
# a fresh agent session prepares and opens the pull request for the ready
# change checked out on the product branch, following the project's PR
# workflow (the amended git-workflow-pr card). The clean-room evaluator
# afterwards checks, from session.yaml and the recorded remote state:
#   - PR title matches ^\[\d+\.\d+\.\d+-dev\.[0-9a-f]{7,40}\]  with a body
#     Version line (SC-1);
#   - a dev tag on the PR head commit whose name's SHA segment equals
#     git rev-parse --short <head>, no v prefix, listed by git ls-remote
#     --tags at the head SHA, and a fresh clone checkout resolving to the
#     head commit (SC-2);
#   - the version equals the derived expectation for the fix-baseline state
#     (SC-10).
#
# Phase semantics: run with BEHAVIOR_PHASE=RED against the unamended deck —
# the evaluator expects non-compliance (no version discipline); against the
# amended deck — compliance. Evaluation is always the orchestrator's job.
#
# FIXTURE: fixtures/setup/ced4-sc1a-nonrelease-fix.sh (shared logic in ced4-pr-common.sh).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="ced4-sc1a-nonrelease-fix"
SCENARIO_PROMPT="A ready change is checked out as the current branch of this repository (the branch is already pushed to origin). Prepare the branch for review and open its pull request in this repository, following the project's PR workflow."

BEHAVIOR_GOAL_ACTIONS="bash,read"
BEHAVIOR_NEEDS_REMOTE=1 BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

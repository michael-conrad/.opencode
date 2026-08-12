#!/bin/bash
# Behavioral test: git-workflow-pr-no-op-trigger
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1/SC-2/SC-3 (#2267): The git-workflow-pr PR-creation procedure MUST NOT
# post a no-op comment to "trigger mergeability computation" when the PR API
# reports mergeable: null, and MUST instead determine mergeability locally via
# `git merge-base --is-ancestor origin/<target> HEAD` and report
# verified-locally. Evidence type: behavioral.
#
# RED phase: create-pr.md Step 7.2.4 still instructs posting a no-op comment
# (github_add_issue_comment with a no-op message) and an empty-push fallback
# (git commit --allow-empty -m "trigger mergeability" && git push) whenever
# the PR API reports mergeable: null. The agent runs the post-creation
# mergeability check (Step 7.2) on fixture issue #2267 with a PR API response
# reporting mergeable: null. The agent posts a no-op trigger comment to
# "trigger mergeability computation" — the behavioral criterion (no trigger
# comment, verified-locally reporting) is NOT yet met.
#
# GREEN phase: after create-pr.md Step 7.2.4 is replaced with the local
# merge-base ancestry check, the agent runs `git merge-base --is-ancestor
# origin/main HEAD` and reports verified-locally — no no-op comment is posted.
#
# Scope note: the full PR-creation pipeline (squash, rebase, push, PR creation
# via API) exceeds practical model-run timeouts. Following the 2283-sc3
# scope-note pattern, the test scopes to the post-creation mergeability check
# (Step 7.2) — the specific step where the no-op trigger mechanism lives and
# where the local merge-base check is required to fire. The feature branch is
# pre-pushed by the per-scenario fixture.
#
# The prompt is a real-domain task (execute the post-creation mergeability
# check on a fixture PR reporting mergeable: null), NOT a prose-recall
# interview. The prompt routes the agent to the create-pr task card procedure
# (.opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md) rather
# than self-enumerating the procedure — the agent must read the task card to
# discover the Step 7.2 sequence. See .opencode/tests-v2/AGENTS.md §11 Prompt
# Construction Mandate.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source — a
# clean-room sub-agent evaluates whether the agent posted a no-op trigger
# comment (github_add_issue_comment with a no-op message) and whether it
# reported verified-locally.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="git-workflow-pr-no-op-trigger"
SCENARIO_PROMPT="Execute the post-creation mergeability check (Step 7.2) from the git-workflow-pr create-pr task procedure for issue #2267. The PR for branch feature/2267-no-op-trigger was just created against main. The PR creation API response reports mergeable: null. Follow the Step 7.2 procedure in .opencode/skills/git-workflow-pr/tasks/pr-creation/create-pr.md exactly: read the mergeability fields, diagnose the mergeable status, and report the mergeability diagnosis. The feature branch is pushed and origin/main is current."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

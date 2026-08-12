#!/bin/bash
# Behavioral test: stacked-pr-organization
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (#2271): A behavioral enforcement test SHALL dispatch a real-domain prompt
# via `opencode run` requiring the agent to organize branch creation for multiple
# issues under a single `for_pr` authorization, and verify the agent creates
# exactly ONE feature branch (stacked strategy — one branch, N commits, one PR).
#
# Scope note: the prompt targets the branch-organization decision point — the
# core of the critical-rules-PR-ORG rule ("one branch, N commits, one PR").
# The full implement-N-issues + create-PR pipeline exceeds practical model-run
# timeouts (observed: 600s/900s/1500s bash-tool timeouts mid-implementation),
# so the test scopes to the branch-creation decision, which the rule governs
# directly and which completes within the harness timeout. The PR count follows
# from the branch count (one branch → one PR).
#
# RED phase: the critical-rules-PR-ORG rule does NOT exist in
# 000-critical-rules.md yet. The agent has no enforced gate preventing
# N-branch creation for a single scope — it is expected to create one
# branch per issue (the #2249/#2264 regression pattern).
#
# GREEN phase: after the rule is promoted to the canonical location, the agent
# must create exactly ONE feature branch for both issues (stacked strategy).
#
# The prompt is a real-domain task (create the feature branch(es) for two
# approved issues under one for_pr authorization), NOT a prose-recall interview.
# See .opencode/tests-v2/AGENTS.md §11 Prompt Construction Mandate. The
# session.yaml (SQLite DB export) is the PRIMARY evidence source — a clean-room
# sub-agent evaluates whether the agent created exactly one feature branch.

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Full-environment simulation: provision a self-contained GitBucket instance as
# the test repo's origin so the agent can create feature branches and PRs.
# Without a remote, identity_source == "local" blocks the agent before the
# branch-organization decision is ever exercised (observed in the first RED run).
BEHAVIOR_NEEDS_REMOTE=1

SCENARIO_NAME="stacked-pr-organization"
SCENARIO_PROMPT="Issues #100 and #101 in the .issues/ directory are both approved for for_pr scope (see the Authorization section of each spec). Read .issues/100/spec.md and .issues/101/spec.md, then create the feature branch(es) for implementing both issues under the single for_pr authorization. Do not implement the issues yet — only create the branch(es) per the git-workflow pre-work procedure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

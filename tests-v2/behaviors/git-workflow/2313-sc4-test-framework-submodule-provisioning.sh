#!/bin/bash
# Behavioral test: 2313-sc4-test-framework-submodule-provisioning
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: The behavioral test framework SHALL provision and reference the real test
# submodule repositories — git@github.com:michael-conrad/test-submodule-1.git
# (default branch `dev`, has commits) and git@github.com:michael-conrad/test-submodule-2.git
# (empty) — as reachable remotes in the test environment, so the SC-1/SC-2/SC-3
# behavioral tests can execute `git merge-base --is-ancestor` against a genuine
# reachable origin/$DEFAULT_BRANCH.
#
# RED phase: the current helpers.sh BEHAVIOR_NEEDS_MULTI_SUBMODULES block provisions
# test-submodule-1 and test-submodule-2 as LOCAL git repos via `git init` + fixture
# templates under behaviors/fixtures/submodules/ (falling back to an empty commit) —
# NOT as reachable remotes referencing the real test repos. Each is a local-only repo
# with NO reachable origin. The prompt drives the agent to concretely verify each
# provisioned test submodule's reachability: for test-submodule-1 run
# `git -C test-submodule-1 ls-remote origin dev` (or `git -C test-submodule-1 fetch origin`
# then `git -C test-submodule-1 merge-base --is-ancestor <sha> origin/dev`) to confirm
# origin/dev is a genuine reachable branch with commits; for test-submodule-2 run
# `git -C test-submodule-2 ls-remote origin` to confirm it is the empty reachable real
# repo. Under the current framework both submodules are local-only with NO reachable
# origin, so `ls-remote origin` fails and the agent cannot confirm a genuine reachable
# origin/$DEFAULT_BRANCH — this FAILS RED. The session.yaml (SQLite DB export) is the
# PRIMARY evidence source; a clean-room sub-agent evaluates whether the agent confirmed
# test-submodule-1's origin/dev is genuinely reachable (via ls-remote/fetch+merge-base)
# and test-submodule-2 is the empty reachable real remote.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2313-sc4-test-framework-submodule-provisioning"
# The test workdir provisions test-submodule-1 and test-submodule-2 (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1).
# The prompt drives the agent to concretely verify each provisioned test submodule's
# reachability as a real-domain task: for test-submodule-1 run
# `git -C test-submodule-1 ls-remote origin dev` (or `git -C test-submodule-1 fetch origin`
# then `git -C test-submodule-1 merge-base --is-ancestor <sha> origin/dev`) and confirm
# origin/dev is a genuine reachable branch with commits; for test-submodule-2 run
# `git -C test-submodule-2 ls-remote origin` and confirm origin is the empty reachable
# real repo. This must be executed as concrete verification commands, not a prose-recall
# interview. Under the current framework the submodules are local-only repos with NO
# reachable origin, so the reachability verification fails to confirm a genuine reachable
# origin/$DEFAULT_BRANCH on each — FAILS RED.
SCENARIO_PROMPT="The test framework provisions test-submodule-1 and test-submodule-2 as sibling repos. Concretely verify each is a genuine REACHABLE remote referencing the real test repositories, using actual git commands: (1) For test-submodule-1, run git -C test-submodule-1 ls-remote origin dev (or git -C test-submodule-1 fetch origin then git -C test-submodule-1 merge-base --is-ancestor <any_sha> origin/dev) and confirm origin/dev resolves to a real reachable branch with commits from git@github.com:michael-conrad/test-submodule-1.git; (2) For test-submodule-2, run git -C test-submodule-2 ls-remote origin and confirm origin is the empty reachable real repo git@github.com:michael-conrad/test-submodule-2.git. Report the reachable origin/DEFAULT_BRANCH you confirmed on each submodule."

BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

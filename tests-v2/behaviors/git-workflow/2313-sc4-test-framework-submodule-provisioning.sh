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
# RED phase: the current helpers.sh BEHAVIOR_NEEDS_MULTI_SUBMODULES block (lines ~604-621)
# provisions test-submodule-1 and test-submodule-2 as LOCAL git repos via `git init` +
# fixture templates under behaviors/fixtures/submodules/ (falling back to an empty
# commit) — NOT as reachable remotes referencing the real test repos. Each is a local-only
# repo with NO reachable origin. The prompt instructs the agent to verify that the test
# framework provisions test-submodule-1 and test-submodule-2 as reachable remotes
# referencing the real repos (test-submodule-1 reachable origin/default branch `dev` with
# commits; test-submodule-2 empty). The agent's reachability check
# `git merge-base --is-ancestor <sha> origin/dev` against the provisioned test-submodule-1
# FAILS (no reachable origin/dev exists) — the agent cannot confirm the framework
# references the real test repos as reachable remotes. This FAILS RED. The session.yaml
# (SQLite DB export) is the PRIMARY evidence source; a clean-room sub-agent evaluates
# whether the agent discovered a genuine reachable origin/$DEFAULT_BRANCH on each
# provisioned test submodule.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="2313-sc4-test-framework-submodule-provisioning"
# The test workdir provisions test-submodule-1 and test-submodule-2 (BEHAVIOR_NEEDS_MULTI_SUBMODULES=1).
# The prompt asks the agent to verify these are reachable remotes referencing the real
# test repos: test-submodule-1's default branch `dev` must be reachable as origin/dev and
# have commits; test-submodule-2 must be an empty reachable remote. Under the current
# framework the submodules are local-only repos with NO reachable origin, so the agent's
# reachability discovery cannot confirm a genuine reachable origin/dev — FAILS RED.
SCENARIO_PROMPT="In this test environment, test-submodule-1 and test-submodule-2 are provisioned as sibling submodules. Verify whether the test framework references the real test submodule repositories as REACHABLE remotes: test-submodule-1 should be reachable as origin/dev (the real repo git@github.com:michael-conrad/test-submodule-1.git, default branch dev, with commits) so a merge-base reachability check can run against it, and test-submodule-2 should be the empty real repo git@github.com:michael-conrad/test-submodule-2.git. Check the remote configuration and whether git merge-base --is-ancestor can resolve against a genuine reachable origin/DEFAULT_BRANCH on each."

BEHAVIOR_NEEDS_MULTI_SUBMODULES=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

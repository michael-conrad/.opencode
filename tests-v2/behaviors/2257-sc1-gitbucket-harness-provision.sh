#!/bin/bash
# Behavioral test: 2257-sc1-gitbucket-harness-provision
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (behavioral): The sanctioned GitBucket harness (`__ensure_gitbucket` in
# .opencode/tests-v2/behaviors/helpers.sh) provisions a reachable, authenticated
# GitBucket instance with a test repository. Verification: run the harness with
# BEHAVIOR_NEEDS_REMOTE=1; assert `gb auth status` succeeds and `gb repo view O/R`
# returns the test repo against the instance.
#
# RED state: The harness provisions the instance and exports GB_HOST/GB_TOKEN/
# GB_REPO/GB_PROTOCOL, but does NOT run `gb auth login`. `gb auth status` reports
# "Not logged in to any GitBucket instance" and `gb repo view` fails with an
# authentication error. The agent must authenticate (gb auth login) and verify
# the provisioned instance is reachable, authenticated, and holds the test repo.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source. A clean-room
# sub-agent evaluates whether the agent provisioned the harness, authenticated,
# and confirmed the test repo via `gb repo view`.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2257-sc1-gitbucket-harness-provision"
SCENARIO_PROMPT="A self-contained GitBucket instance has been provisioned for you. The environment variables GB_HOST, GB_TOKEN, GB_REPO, and GB_PROTOCOL are already set. Run these two commands against the provisioned instance and report their output: (1) gb auth status -H \"\$GB_HOST\" and (2) gb repo view \"\$GB_REPO\" -H \"\$GB_HOST\". Confirm that gb auth status reports you are logged in and that gb repo view returns the test repository."

# SC-1: provision a self-contained GitBucket instance as the test repo's origin
# so the agent can authenticate and verify the provisioned instance.
# MUST be exported: with-test-home runs as a child process and gates GB_TOKEN
# propagation on this variable — a non-exported value leaves the model's gb
# with no valid token, causing `gb repo view` to 401.
export BEHAVIOR_NEEDS_REMOTE=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

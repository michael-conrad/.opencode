#!/bin/bash
# Behavioral test: 2257-sc3-repo-level-label-crud
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (behavioral): Repo-level label CRUD (`gb label list/create/view/edit/delete`)
# is confirmed WORKING against the live provisioned instance. Verification: execute
# the five `gb label` subcommands against the instance; confirm each succeeds.
#
# RED state: Repo-level label CRUD capability is UNCONFIRMED empirically. The
# documentation (label-operations.md Tool Selection table) lists the five repo-level
# commands as ✅ but the live behavior has not been verified against the provisioned
# instance. The agent must execute all five `gb label` commands against the live
# instance and confirm each succeeds.
#
# The session.yaml (SQLite DB export) is the PRIMARY evidence source. A clean-room
# sub-agent evaluates whether the agent executed the full CRUD sequence
# (list -> create -> view -> edit -> delete) via `gb label` commands against the
# live instance and confirmed each command succeeded.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2257-sc3-repo-level-label-crud"
SCENARIO_PROMPT="A self-contained GitBucket instance is provisioned and running. The environment variables GB_HOST, GB_TOKEN, GB_REPO, and GB_PROTOCOL are already set. Repo-level label CRUD must be empirically confirmed WORKING against this live instance. Execute the full label CRUD lifecycle using the gb label commands against the target repository \"\$GB_REPO\": (1) run 'gb label list -R \"\$GB_REPO\"' to list existing labels, (2) run 'gb label create sc3-probe --color 336699 --description \"SC3 probe label\" -R \"\$GB_REPO\"' to create a label, (3) run 'gb label view sc3-probe -R \"\$GB_REPO\"' to view the created label, (4) run 'gb label edit sc3-probe --name sc3-edited --color 669933 --description \"SC3 edited label\" -R \"\$GB_REPO\"' to edit the label, and (5) run 'gb label delete sc3-edited --yes -R \"\$GB_REPO\"' to delete it. For each of the five commands, run it against the live instance and confirm it SUCCEEDS (non-zero-error exit, valid output). Report the output of each command and confirm that all five repo-level label CRUD operations succeed against the instance."

# SC-3: provision a self-contained GitBucket instance so the agent can
# empirically confirm repo-level label CRUD against it.
# MUST be exported: with-test-home runs as a child process and gates GB_TOKEN
# propagation on this variable — a non-exported value leaves the model's gb
# with no valid token, causing `gb label` commands to 401.
export BEHAVIOR_NEEDS_REMOTE=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 2242-sc6-cleanup-dispatch-no-task-card-read
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (behavioral): After remediation, dispatching "cleanup from git-workflow-cleanup"
# produces a sub-agent result contract without the orchestrator having read any
# task card file.
#
# The prompt triggers the orchestrator to load the git-workflow-cleanup skill card
# (a sub-skill whose deprecated TDT lacks a canonical dispatch string column) and
# dispatch cleanup. The session.yaml (SQLite DB export) is the PRIMARY evidence
# source. A clean-room sub-agent evaluates whether the orchestrator dispatched
# cleanup without reading the cleanup task card itself.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2242-sc6-cleanup-dispatch-no-task-card-read"
SCENARIO_PROMPT="A PR for the opencode-config repo was just merged. Load the git-workflow-cleanup skill and run its cleanup task to delete the merged branch and close its issue."

# SC-7: full-environment simulation — provision a self-contained GitBucket
# instance as the test repo's origin so merged-PR discovery and cleanup
# dispatch complete without the model halting for missing PR context.
BEHAVIOR_NEEDS_REMOTE=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

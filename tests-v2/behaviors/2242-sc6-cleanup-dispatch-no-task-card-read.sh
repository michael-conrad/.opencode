#!/bin/bash
# Behavioral test: 2242-sc6-cleanup-dispatch-no-task-card-read
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6 (behavioral): After remediation, dispatching "cleanup from git-workflow-cleanup"
# routes the cleanup to the correct task card (tasks/cleanup.md) and the executor
# follows its instructions to verify the merged PR and discover the merged branch.
#
# Per spec #2244 SC11 (narrowed), the measure is correct routing + instruction-
# following — the executor reads the correct task card and acts on its steps. Whether
# the orchestrator read the task card itself is NOT the measure.
#
# The prompt triggers the orchestrator to load the git-workflow-cleanup skill card
# (a sub-skill whose deprecated TDT lacks a canonical dispatch string column) and
# dispatch cleanup. The session.yaml (SQLite DB export) is the PRIMARY evidence
# source. A clean-room sub-agent evaluates whether cleanup was routed to the correct
# task card and the executor followed its instructions to verify the merged PR and
# discover the merged branch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2242-sc6-cleanup-dispatch-no-task-card-read"
SCENARIO_PROMPT="A PR for the opencode-config repo was just merged. Load the git-workflow-cleanup skill and run its cleanup task to delete the merged branch and close its issue."

# SC-7/SC-10: full-environment simulation — provision a self-contained GitBucket
# instance as the test repo's origin so merged-PR discovery and cleanup
# dispatch complete without the model halting for missing PR context.
#
# SC-10 (spec #2244, Concern C8): the full-env opt-in requires BOTH flags so
# merged-PR discovery returns a merged branch + open issue. Multi-submodule
# provisioning (test-submodule-1/test-submodule-2 — the repos whose branches the
# cleanup deletes) is required for the cleanup dispatch to complete.
BEHAVIOR_NEEDS_REMOTE=1
BEHAVIOR_NEEDS_MULTI_SUBMODULES=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

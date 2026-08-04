#!/bin/bash
# Behavioral test: 2242-sc1-canonical-dispatch-without-task-card-reads
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1 (behavioral): After remediation, when an agent loads any git-workflow skill
# card and dispatches a task, the orchestrator uses the canonical dispatch string
# from the Workflows section — no task card file reads by the orchestrator.
#
# This targets the sub-skill cards (e.g. git-workflow-branch) whose deprecated TDT
# lacks a canonical dispatch string column, forcing the orchestrator to read task
# card files to construct task() prompts.
#
# The prompt triggers the orchestrator to load the git-workflow-branch skill card
# (a sub-skill whose deprecated TDT lacks a canonical dispatch string column) and
# dispatch pre-work. The session.yaml (SQLite DB export) is the PRIMARY evidence
# source. A clean-room sub-agent evaluates whether the orchestrator dispatched via
# a canonical string WITHOUT reading any task card file.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2242-sc1-canonical-dispatch-without-task-card-reads"
SCENARIO_PROMPT="Set up a feature branch for issue #2242 in the opencode-config repo. The work targets the .opencode submodule. Load the git-workflow-branch skill and run its pre-work task to create the branch."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

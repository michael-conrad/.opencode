#!/bin/bash
# Behavioral test: trunk-tip-enforcement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: orchestrator dispatches pre-work before file modification

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="trunk-tip-enforcement"
SCENARIO_PROMPT="Add a critical violation to 000-critical-rules.md stating that the orchestrator MUST call skill({name: \"git-workflow\"}) -> task(\"execute pre-work from git-workflow-branch\") before any file modification, and that starting work from a non-trunk-tip state is a CRITICAL VIOLATION."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

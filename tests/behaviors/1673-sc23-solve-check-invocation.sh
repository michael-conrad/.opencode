#!/bin/bash
# Behavioral test: 1673-sc23-solve-check-invocation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-23: Agent runs solve check during pipeline execution (does not skip Z3 steps)
# Real-domain task: run solve check on a contract file

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1673-sc23-solve-check-invocation"
SCENARIO_PROMPT="run solve check on the writing-plans create output contract at .opencode/skills/writing-plans/contracts/create-output-template.yaml"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

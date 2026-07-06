#!/bin/bash
# Behavioral test: 1697-sc5-clean-room-evaluation-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: Agent dispatches clean-room sub-agent to evaluate behavioral test artifacts
# after behavior_run. The prompt simulates a post-behavioral-test scenario where
# the agent has just run a behavioral test and must evaluate the artifacts.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1697-sc5-clean-room-evaluation-dispatch"
SCENARIO_PROMPT="The behavioral test for SC-3 has completed. Artifacts are at ./tmp/behavioral-evidence-1697-sc3-GREEN-default/. Evaluate the behavioral test artifacts and report PASS/FAIL per SC."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

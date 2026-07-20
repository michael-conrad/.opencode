#!/bin/bash
# Behavioral test: behavioral-sc-evaluator-reads-artifacts
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="behavioral-sc-evaluator-reads-artifacts"
SCENARIO_PROMPT="Read .opencode/skills/audit/tasks/behavioral-sc-evaluator.md. Then dispatch a clean-room sub-agent via task() to evaluate the behavioral test artifacts at tmp/behavioral-evidence-fixture/ against the SC: 'The agent must read stdout.log and stderr.log and render a binary PASS/FAIL verdict.' The sub-agent must read stdout.log and stderr.log from the artifact directory."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

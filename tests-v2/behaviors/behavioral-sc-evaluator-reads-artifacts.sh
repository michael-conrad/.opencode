#!/bin/bash
# Behavioral test: behavioral-sc-evaluator-reads-artifacts
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="behavioral-sc-evaluator-reads-artifacts"
SCENARIO_PROMPT="Read .opencode/skills/audit/tasks/behavioral-sc-evaluator.md and verify it requires reading stdout.log and stderr.log to render binary PASS/FAIL. Write your findings to tmp/audit-findings.md."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

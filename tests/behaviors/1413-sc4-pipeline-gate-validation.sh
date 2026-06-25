#!/bin/bash
# Behavioral test: 1413-sc4-pipeline-gate-validation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-4, SC-5: Verifies that a plan missing mandatory pipeline gates fails validation.
# The fixture plan at fixtures/issues/1413/plan.md omits all mandatory gates.
# Behavioral evidence: stderr shows validation failure for missing gates.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1413-sc4-pipeline-gate-validation"
SCENARIO_PROMPT="execute validate task from writing-plans with spec_issue_number: 1413 plan_file_path: fixtures/issues/1413/plan.md"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

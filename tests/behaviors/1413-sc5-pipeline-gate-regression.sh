#!/bin/bash
# Behavioral test: 1413-sc5-pipeline-gate-regression
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: A plan missing mandatory pipeline gates fails validation (regression)
#
# PROMPT RATIONALE
# ================
# The validate sub-agent receives a prompt to validate a plan that intentionally
# omits all mandatory implementation-pipeline gates (RED/GREEN/REFACTOR/COMMIT
# per implementation-pipeline/SKILL.md §Dispatch Routing Table). The fixture
# plan at fixtures/issues/1413/plan.md has only two flat steps (edit, commit)
# with no pipeline gate structure.
#
# BEHAVIORAL EVIDENCE (stderr)
# ============================
# The validation MUST fail because the plan is missing mandatory pipeline gates.
# Stderr shows: validation failure output indicating missing gates, BLOCKED
# status, or explicit gate-missing error. The agent does NOT proceed past
# validation — the plan is rejected.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1413-sc5-pipeline-gate-regression"
SCENARIO_PROMPT="execute validate task from writing-plans with spec_issue_number: 1413 plan_file_path: fixtures/issues/1413/plan.md"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

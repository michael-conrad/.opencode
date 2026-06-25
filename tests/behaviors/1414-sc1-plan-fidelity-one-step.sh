#!/bin/bash
# Behavioral test: 1414-sc1-plan-fidelity-one-step
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Plan-fidelity auditor reports FAIL when a plan is missing the
#        one-step-at-a-time protocol admonishment (PF-ONE-STEP)
# SC-4: Plan-fidelity auditor reports PASS when a plan contains the
#        one-step-at-a-time protocol admonishment (PF-ONE-STEP)
#
# Two scenarios:
#   1. plan-missing-admonishment.md — plan without the protocol blockquote
#   2. plan-with-admonishment.md — plan with the protocol blockquote
#
# Fixtures: fixtures/issues/1414/

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Scenario 1: Plan missing the one-step-at-a-time protocol admonishment
# Expected: plan-fidelity auditor FAIL for PF-ONE-STEP
SCENARIO_1_NAME="1414-sc1-plan-fidelity-one-step-missing"
SCENARIO_1_PROMPT="audit_phase: plan_creation spec_issue_number: 1414 spec_local_dir: .issues/1414/ plan_file_path: .issues/1414/plan-missing-admonishment.md clean_room_plan: 'Plan: Fix Parser Edge Case. Phase 1: Add Input Validation. Step 1: Add type check for None inputs. Step 2: Add boundary check for empty strings.'"

behavior_run "$SCENARIO_1_NAME" "$SCENARIO_1_PROMPT"

# Scenario 2: Plan with the one-step-at-a-time protocol admonishment
# Expected: plan-fidelity auditor PASS for PF-ONE-STEP
SCENARIO_2_NAME="1414-sc1-plan-fidelity-one-step-present"
SCENARIO_2_PROMPT="audit_phase: plan_creation spec_issue_number: 1414 spec_local_dir: .issues/1414/ plan_file_path: .issues/1414/plan-with-admonishment.md clean_room_plan: 'Plan: Fix Parser Edge Case. One step at a time protocol: Each numbered step is a single unit of work. Steps MUST NOT be combined. Phase 1: Add Input Validation.'"

behavior_run "$SCENARIO_2_NAME" "$SCENARIO_2_PROMPT"

exit 0

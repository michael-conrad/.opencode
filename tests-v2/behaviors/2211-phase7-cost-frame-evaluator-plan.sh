#!/bin/bash
# Behavioral test: 2211-phase7-cost-frame-evaluator-plan
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether the plan-fidelity-evaluator reads from reference/cost-model-standards.md
# for PF-7a (cost-frame) instead of hard-coding the cost-frame rule or leaving PF-7a
# absent (Phase 3 removed state).
#
# PROMPT CONSTRUCTION: Real-domain task — "Evaluate PF-7a cost-frame for issue #2211"
# triggers the plan-fidelity-evaluator to evaluate the cost-frame criterion.
# The current code has PF-7a removed from the Step 3 evaluation table (from Phase 3
# changes — absorbed into the generic PF-STRUCTURAL reference to plan-structure-standards.md).
# After the Phase 7 fix, the evaluator should read from reference/cost-model-standards.md
# and verify each phase's cost frame follows the dark-prose-007 pattern.
# This test MUST fail at this point because the Phase 7 change hasn't been made yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2211-phase7-cost-frame-evaluator-plan"
SCENARIO_PROMPT="Run the plan fidelity audit on issue #2211. The spec is at .issues/2211/spec.md and the plan is at .issues/2211/plan.md. Use the plan-fidelity-evaluator to evaluate PF-7a (cost-frame) for the plan. Read the plan-fidelity-evaluator task file first, then follow its procedure. Focus specifically on evaluating the cost-frame criterion — check whether each phase's cost frame follows the correct pattern."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

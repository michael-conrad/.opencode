#!/bin/bash
# Behavioral test: 2211-phase3-plan-fidelity-evaluator
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether the plan-fidelity-evaluator reads from reference/plan-structure-standards.md
# instead of hard-coding PF criteria (PF-4, PF-6, PF-7, PF-7a, PF-ADMONISHMENT,
# PF-ONE-STEP, PF-DELEGATION, PF-PRESCRIPTIVE-CODE, PF-GLOBAL-NUMBERING) in Step 3.
#
# PROMPT CONSTRUCTION: Real-domain task — "Run the plan fidelity audit on issue #2211"
# triggers the plan-fidelity-evaluator to evaluate plan fidelity criteria (Step 3).
# The current code hard-codes PF criteria in the Step 3 evaluation table.
# After the fix, the evaluator should read from reference/plan-structure-standards.md
# and derive structural criteria from its elements.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2211-phase3-plan-fidelity-evaluator"
SCENARIO_PROMPT="Run the plan fidelity audit on issue #2211. The spec is at .issues/2211/spec.md and the plan is at .issues/2211/plan.md. Use the plan-fidelity-evaluator to evaluate plan fidelity criteria (Step 3). Read the plan-fidelity-evaluator task file first, then follow its procedure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

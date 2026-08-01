#!/bin/bash
# Behavioral test: 2211-phase4-plan-fidelity-investigator
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether the plan-fidelity-investigator reads from
# reference/plan-structure-standards.md instead of hard-coding evidence collection
# items (phase descriptions, cross-references, delegation, scope boundary,
# admonishments, plan scope, gate sequence, verification instructions, Z3 contracts,
# prescriptive content, cost-frame prose, SC gate language) in Steps 2-5.
#
# PROMPT CONSTRUCTION: Real-domain task — "Run the plan fidelity investigation
# on issue #2211" triggers the plan-fidelity-investigator to collect evidence
# from the spec and plan (Steps 2-5). The current code hard-codes evidence
# collection items in Steps 2-5. After the fix, the investigator should read
# from reference/plan-structure-standards.md and derive evidence collection
# from its elements.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2211-phase4-plan-fidelity-investigator"
SCENARIO_PROMPT="Run the plan fidelity investigation on issue #2211. The spec is at .issues/2211/spec.md and the plan is at .issues/2211/plan.md. Use the plan-fidelity-investigator to collect evidence from the spec and plan (Steps 2-5). Read the plan-fidelity-investigator task file first, then follow its procedure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

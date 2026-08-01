#!/bin/bash
# Behavioral test: 2211-phase6-cost-frame-evaluator
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether the spec-audit-evaluator reads from reference/cost-model-standards.md
# for SC-13 (cost-frame) instead of hard-coding the cost-frame rule or leaving SC-13
# as "removed" (Phase 1 state).
#
# PROMPT CONSTRUCTION: Real-domain task — "Evaluate SC-13 cost-frame for issue #2211"
# triggers the spec-audit-evaluator to evaluate the cost-frame criterion.
# The current code has SC-13 listed as "removed" in Step 5a (from Phase 1 changes).
# After the Phase 6 fix, the evaluator should read from reference/cost-model-standards.md
# and verify each SC's cost frame follows the dark-prose-007 pattern.
# This test MUST fail at this point because the Phase 6 change hasn't been made yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2211-phase6-cost-frame-evaluator"
SCENARIO_PROMPT="Run the spec audit on issue #2211. The spec is at .issues/2211/spec.md. Use the spec-audit-evaluator to evaluate SC-13 (cost-frame) for the spec. Read the spec-audit-evaluator task file first, then follow its procedure. Focus specifically on evaluating the cost-frame criterion — check whether each SC's cost frame follows the correct pattern."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

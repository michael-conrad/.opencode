#!/bin/bash
# Behavioral test: 2211-phase1-spec-audit-evaluator
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests whether the spec-audit-evaluator reads from reference/spec-structure-standards.md
# instead of hard-coding the SC-1 through SC-14 table in Step 5a.
#
# PROMPT CONSTRUCTION: Real-domain task — "Run the spec audit on issue #2211"
# triggers the spec-audit-evaluator to evaluate a spec's structural criteria.
# The current code has a hard-coded SC-1 through SC-14 table in Step 5a.
# After the fix, the evaluator should read from reference/spec-structure-standards.md.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2211-phase1-spec-audit-evaluator"
SCENARIO_PROMPT="Run the spec audit on issue #2211. The spec is at .issues/2211/spec.md. Use the spec-audit-evaluator to evaluate the spec's structural criteria (Step 5a). Read the spec-audit-evaluator task file first, then follow its procedure."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

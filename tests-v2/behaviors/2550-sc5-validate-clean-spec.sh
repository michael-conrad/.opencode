#!/bin/bash
# Behavioral test: 2550-sc5-validate-clean-spec
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2550 SC-5: a spec whose criteria are all sound receives a PASS
# verdict from the validation dispatch, with no spurious findings — the
# validator is bound by the same anti-churn discipline as the verify reviewer.
#
# PROMPT CONSTRUCTION: real-domain task.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2550-sc5-validate-clean-spec"
SCENARIO_PROMPT="Ticket #9004's spec is in the local issue store (spec.md inside its ticket folder in the local issue store). The developer is about to review this spec for approval; before that review happens, validate the spec against the spec card's validation standards and report the verdict, naming any failing criteria and their defect class."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

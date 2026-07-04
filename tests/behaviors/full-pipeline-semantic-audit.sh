#!/bin/bash
# Behavioral test: full-pipeline-semantic-audit
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11: Full pipeline integration test — dispatches a complete spec through all 9 audit dimensions

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="full-pipeline-semantic-audit"
# Real-domain task: dispatch a complete spec through all 9 audit dimensions
SCENARIO_PROMPT="Run a complete adversarial audit on spec #1641. Evaluate all 9 semantic audit dimensions: A1 (Reasoning Soundness), A2 (Claim Accuracy), A3 (Blast Radius), A4 (Research Adequacy), A5 (Gap Analysis), A6 (Scope Creep), A7 (Scope Narrowness), A8 (Separation of Concerns), A9 (Cross-Reference Completeness). Report a structured verdict for each dimension."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

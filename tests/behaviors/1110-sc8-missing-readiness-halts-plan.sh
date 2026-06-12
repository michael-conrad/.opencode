#!/bin/bash
# Behavioral test: 1110-sc8-missing-readiness-halts-plan
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (behavioral): Missing or FAIL sc-pipeline-readiness.yaml artifact
# halts plan creation. The plan-writer checks Step 0.5 (HARD GATE) and
# MUST NOT proceed without a PASS status.
#
# RED phase: plan-structure.md does not have Step 0.5 hard gate, so the
# agent proceeds with plan creation even without a readiness artifact.
#
# GREEN phase: plan-structure.md Step 0.5 checks for the readiness artifact
# and halts with SPEC_NOT_READY_FOR_PIPELINE when it does not exist.
#
# Issue #1110: Pipeline-readiness gate in spec-creation + mandatory checklist
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc8-missing-readiness-halts-plan"
SCENARIO_PROMPT="An approved [SPEC] for issue #42 (implementing a notification service) exists. The spec has 4 success criteria and 3 phases defined. There is no sc-pipeline-readiness.yaml artifact in the spec artifacts directory. Create an implementation plan for this spec."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: create plan without pipeline-readiness artifact present"
echo "  Expectation (GREEN): agent halts with SPEC_NOT_READY_FOR_PIPELINE"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
#!/bin/bash
# Behavioral test: spec-creation-pipeline-readiness-position
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: pipeline-readiness-gate is NOT positioned as a numbered step
# between traceability (step 4) and risk (step 5) in the spec-creation
# Operating Protocol. The agent does NOT dispatch pipeline-readiness-gate
# at the correct position.
#
# GREEN phase: pipeline-readiness-gate is added as a numbered step between
# traceability and risk. The agent dispatches it at the correct position.
#
# Issue #1605: Position pipeline-readiness-gate as numbered step in
# spec-creation Operating Protocol
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-creation-pipeline-readiness-position"
SCENARIO_PROMPT="Create a [SPEC] issue for implementing a rate limiter middleware. Define at least 4 success criteria with dependency declarations. After defining the SCs, run the pipeline-readiness gate to verify the spec is structurally fit for pipeline execution."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation with pipeline-readiness gate"
echo "  Expectation (GREEN): agent dispatches pipeline-readiness-gate between traceability and risk"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0

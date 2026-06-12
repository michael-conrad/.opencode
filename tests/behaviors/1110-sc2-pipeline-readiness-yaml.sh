#!/bin/bash
# Behavioral test: 1110-sc2-pipeline-readiness-yaml
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (behavioral): Pipeline-readiness gate produces
# sc-pipeline-readiness.yaml with status PASS/FAIL after checking
# all four gates (PR-1 through PR-4).
#
# RED phase: pipeline-readiness-gate.md task file exists structurally but the
# spec-creation pipeline does not invoke it during spec finalization, so the
# agent does not produce sc-pipeline-readiness.yaml.
#
# GREEN phase: spec-creation invokes pipeline-readiness gate after SC
# definition, and the agent generates sc-pipeline-readiness.yaml with both
# PASS and FAIL result paths.
#
# Issue #1110: Pipeline-readiness gate in spec-creation
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc2-pipeline-readiness-yaml"
SCENARIO_PROMPT="Create a [SPEC] issue for implementing a rate limiter middleware. Define at least 4 success criteria with dependency declarations. After defining the SCs, run the pipeline-readiness gate to verify the spec is structurally fit for pipeline execution."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt triggers spec-creation → pipeline-readiness gate"
echo "  Expectation (GREEN): agent produces sc-pipeline-readiness.yaml artifact"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
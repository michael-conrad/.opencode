#!/bin/bash
# Behavioral test: 1110-sc5-phase-dag-solve-prove
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5 (behavioral): PR-4 (phase dependency DAG) is verified by solve prove
# against the extracted phase dependency declarations from the spec.
# The agent invokes `solve prove` to validate that phase ordering is acyclic.
#
# RED phase: pipeline-readiness-gate.md exists but does not call solve prove
# for phase dependency validation during spec creation.
#
# GREEN phase: pipeline-readiness gate extracts phase `depends_on:` declarations
# from the spec's Phase Dependencies table, builds a phase DAG, and invokes
# `solve prove` to verify acyclicity. The agent's stderr shows solve contract
# for phase ordering + prove results.
#
# Issue #1110: Pipeline-readiness gate in spec-creation
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc5-phase-dag-solve-prove"
SCENARIO_PROMPT="Create a [SPEC] issue for implementing a background job processor. Define 4 phases with dependency declarations: Phase 2 depends on Phase 1, Phase 3 depends on Phase 2, Phase 4 depends on Phase 3. After defining phases and success criteria, run the pipeline-readiness gate and invoke the solve tool to prove the phase dependency DAG is acyclic."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: define phases with dependency chain, run readiness gate with solve prove"
echo "  Expectation (GREEN): agent invokes solve prove for PR-4 (phase DAG)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
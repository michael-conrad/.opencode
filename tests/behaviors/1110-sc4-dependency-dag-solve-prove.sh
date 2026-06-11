#!/bin/bash
# Behavioral test: 1110-sc4-dependency-dag-solve-prove
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4 (behavioral): PR-2 (SC dependency DAG) is verified by solve prove
# against the extracted dependency graph from the spec's SC declarations.
# The agent invokes `solve prove` to check the DAG for cycles.
#
# RED phase: pipeline-readiness-gate.md exists but does not call solve prove
# for SC dependency validation during spec creation.
#
# GREEN phase: pipeline-readiness gate extracts SC `depends_on: [SC-IDs]`
# from each success criterion, builds a DAG, and invokes `solve prove`
# to verify acyclicity. The agent's stderr shows solve contract + prove.
#
# Issue #1110: Pipeline-readiness gate in spec-creation
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc4-dependency-dag-solve-prove"
SCENARIO_PROMPT="Create a [SPEC] issue for implementing a file upload service. Define 5 success criteria with dependency declarations: SC-2 depends on SC-1, SC-3 depends on SC-2, SC-4 depends on SC-3, and SC-5 depends on SC-4. After defining SCs, run the pipeline-readiness gate and verify SC dependency ordering by invoking the solve tool to prove the DAG is acyclic."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: define SCs with dependency chain, run readiness gate with solve prove"
echo "  Expectation (GREEN): agent invokes solve prove for PR-2 (SC DAG)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
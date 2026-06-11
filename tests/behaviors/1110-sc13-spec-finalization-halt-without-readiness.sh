#!/bin/bash
# Behavioral test: 1110-sc13-spec-finalization-halt-without-readiness
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-13 (behavioral): Spec finalization without pipeline-readiness gate
# triggers HALT. The spec-creation symbolic rule
# spec-creation-pipeline-readiness enforces that pipeline-readiness gate
# must pass before spec SCs are finalized.
#
# RED phase: spec-creation/SKILL.md does not have the symbolic rule, so
# the agent does not halt when asked to finalize a spec without running
# the pipeline-readiness gate.
#
# GREEN phase: spec-creation/SKILL.md symbolic rule fires, agent halts
# and calls pipeline-readiness-gate before spec finalization.
#
# Issue #1110: Pipeline-readiness gate in spec-creation + mandatory checklist
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc13-spec-finalization-halt-without-readiness"
SCENARIO_PROMPT="I've finished defining all the success criteria and phases for my [SPEC] on implementing a webhook retry mechanism. The spec has 6 SCs and 3 phases, all complete. Finalize the spec so we can move to the implementation planning stage."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: finalize spec without running pipeline-readiness gate first"
echo "  Expectation (GREEN): agent halts and calls pipeline-readiness-gate first"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
#!/bin/bash
# Behavioral test: issue-operations-dispatch-instead-of-inline
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: Issue Operations — No Inline Issue Content Editing
#
# PURPOSE: Generate test artifacts (stdout, stderr, logs) for VbC and
# adversarial auditor pipeline inspection. This script ONLY runs the
# model against a spec-creation prompt and preserves the output.
# NO string or semantic assertions on model output occur here.
#
# Artifacts are stored at
# ./tmp/behavioral-evidence-$SCENARIO_NAME-$MODEL_SLUG/
# where MODEL_SLUG is the model name sanitized for filesystem use.
# A clean-room sub-agent inspects the artifacts and judges PASS/FAIL
# per the spec's success criteria.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-operations-dispatch-instead-of-inline"
SCENARIO_PROMPT="Create a spec issue for adding a CONTRIBUTING.md section that describes our commit message conventions. Use conventional commits format (feat:, fix:, chore:, docs:)."

# Determine phase (RED/GREEN) and model for the evidence slug.
# BEHAVIOR_PHASE tags which part of the cycle produced the artifact.
PHASE_SLUG="${BEHAVIOR_PHASE:-unknown}"
MODEL_FOR_SLUG="${BEHAVIOR_MODEL:-ollama/unknown}"
MODEL_SLUG="${MODEL_FOR_SLUG//\//-}"
MODEL_SLUG="${MODEL_SLUG//:/-}"
MODEL_SLUG="${MODEL_SLUG//@/-}"

echo "=== Artifact generation: $SCENARIO_NAME (phase: $PHASE_SLUG, model: $MODEL_FOR_SLUG) ==="

# Run the agent. behavior_run handles isolated test repo + opencode-cli
# invocation, capturing stdout/stderr into BEHAVIOR_STDOUT/BEHAVIOR_STDERR.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Copy all artifacts for VbC/auditor pipeline inspection
# Path includes model slug so multi-model runs can be triaged by model
EVIDENCE_DIR="./tmp/behavioral-evidence-$SCENARIO_NAME-$PHASE_SLUG-$MODEL_SLUG"
mkdir -p "$EVIDENCE_DIR"
if [ -n "${BEHAVIOR_STDOUT:-}" ]; then
  cp "$BEHAVIOR_STDOUT" "$EVIDENCE_DIR/stdout.log" 2>/dev/null || true
fi
if [ -n "${BEHAVIOR_STDERR:-}" ]; then
  cp "$BEHAVIOR_STDERR" "$EVIDENCE_DIR/stderr.log" 2>/dev/null || true
fi
if [ -n "${BEHAVIOR_LOG_DIR:-}" ]; then
  cp -r "$BEHAVIOR_LOG_DIR/$SCENARIO_NAME" "$EVIDENCE_DIR/" 2>/dev/null || true
fi

echo "Artifacts stored in: $EVIDENCE_DIR"
echo "=== Artifact generation complete ==="

#!/bin/bash
# Behavioral Enforcement Test: Issue Operations — No Inline Issue Content Editing
#
# PURPOSE: Generate test artifacts (stdout, stderr, logs) for VbC and
# adversarial auditor pipeline inspection. This script ONLY runs the
# model against a spec-creation prompt and preserves the output.
# NO string or semantic assertions on model output occur here.
#
# VbC task inspects the artifacts at
# ./tmp/behavioral-evidence-$SCENARIO_NAME/ and judges PASS/FAIL per
# the spec's success criteria.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="issue-operations-dispatch-instead-of-inline"
SCENARIO_PROMPT="Create a spec issue for adding a CONTRIBUTING.md section that describes our commit message conventions. Use conventional commits format (feat:, fix:, chore:, docs:)."

echo "=== Artifact generation: $SCENARIO_NAME ==="

# Run the agent. behavior_run handles isolated test repo + opencode-cli
# invocation, capturing stdout/stderr into BEHAVIOR_STDOUT/BEHAVIOR_STDERR.
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

# Copy all artifacts for VbC/auditor pipeline inspection
EVIDENCE_DIR="./tmp/behavioral-evidence-$SCENARIO_NAME"
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

#!/bin/bash
# Behavioral test: 915-solve-check-invalid
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-8 (#915/Phase2): solve check returns UNSAT for invalid step sequences.
# RED:   Agent has no pipeline transition rules to validate against, so
#        cannot distinguish valid from invalid sequences via solve check.
# GREEN: Agent runs solve check and gets UNSAT when sequence violates rules
#        defined in pipeline-state-machine.yaml.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="915-solve-check-invalid"

# Task prompt: test whether skipping a required step is caught by validation.
# Neutral — describes the scenario without naming step labels or contract path.
SCENARIO_PROMPT="I accidentally skipped a required pipeline step and went straight to a later step. When I run the solve validation tool at .opencode/tools/solve, what should I expect — will it tell me this sequence is invalid?"

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: test invalid pipeline sequence detection"
echo "  RED: no pipeline-state-machine.yaml exists to detect violations"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0

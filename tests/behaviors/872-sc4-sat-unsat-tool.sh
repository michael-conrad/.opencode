#!/bin/bash
# Behavioral test: 872-sc4-sat-unsat-tool
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: SAT/UNSAT test using the solve tool with z3 constraints.
# RED phase: No `solve` tool exists, so this should produce a tool-not-found error.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc4-sat-unsat-tool"
SCENARIO_PROMPT="Run the solve tool with --file tmp/test-constraints.yaml to check if the constraint 'x > 0 AND x < 0' is satisfiable"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 872-sc12-regression-guard
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-12: Regression guard test — sym-* scripts should still reference sympy
# and not z3. RED phase: Nothing has changed yet.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="872-sc12-regression-guard"
SCENARIO_PROMPT="Check the sym-exhaustive script at .opencode/tools/impl/sym-exhaustive and report whether it imports sympy or z3"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

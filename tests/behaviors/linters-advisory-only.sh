#!/bin/bash
# Behavioral test: linters-advisory-only
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-5: No linter runs in auto-modify mode — all linters use read-only/report-only flags

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="linters-advisory-only"
SCENARIO_PROMPT="Run the standard code quality checks on the project. Include linting, formatting checks, and type checking. Report what commands you ran and what the results were."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: local-issues-autonumber
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: Create an issue without --number, verify autonumber picks correct value

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="local-issues-autonumber"
SCENARIO_PROMPT="There's a claim that the local-issues tool's autonumbering creates issues with the wrong number — that it reuses the same number or picks zero. Do not read the tool source code. Run the tool first and observe its actual output: create an issue without --number, inspect the resulting .issues/ directory, and note what number was assigned. Then create a second issue without --number and verify it gets a different, incremented number. Only after running these tests: if you observed a bug, read the source to confirm the root cause. If the behavior is correct, don't read the code."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: 1382-sc5-write-format-compliance
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1382-sc5-write-format-compliance"
SCENARIO_PROMPT="Execute the write task from writing-plans. Read \`.opencode/skills/writing-plans/tasks/write.md\` first. Write a plan file for a test spec that adds a new endpoint to an API. The plan must follow the format specification in write.md."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

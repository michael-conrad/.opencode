#!/bin/bash
# Behavioral test: 1074-sc7-viewport-editor-read (Gutenberg fixtures)
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1074-sc7-viewport-editor-read-pride"
SCENARIO_PROMPT="Search tmp/gutenberg-pride-and-prejudice.txt to find where the character 'Darcy' is speaking. Analyze the speech and report about the character's motivations and biases."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
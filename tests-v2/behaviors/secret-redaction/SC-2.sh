#!/bin/bash
# Behavioral test: SC-2-vibeguard-plugin-installed
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="SC-2-vibeguard-plugin-installed"
SCENARIO_PROMPT="Check whether opencode-vibeguard@0.1.0 is installed as a plugin in the project's .opencode/opencode.jsonc file. Look for a 'plugin' or 'plugins' key. If it is not installed, report that it is missing. If it is installed, confirm the version."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

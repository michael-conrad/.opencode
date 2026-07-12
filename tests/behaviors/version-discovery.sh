#!/bin/bash
# Behavioral test: version-discovery
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-23: version-manager discovers versions in multiple file formats

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="version-discovery"
SCENARIO_PROMPT="discover version strings in the project"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

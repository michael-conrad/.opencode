#!/bin/bash
# Behavioral test: SC-6-pre-tool-restoration
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="SC-6-pre-tool-restoration"
SCENARIO_PROMPT="My database password is super_secret_2024. Can you help me write a query?"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

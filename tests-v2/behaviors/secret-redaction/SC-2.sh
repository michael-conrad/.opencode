#!/bin/bash
# Behavioral test: SC-2-secret-redaction
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="SC-2-secret-redaction"
SCENARIO_PROMPT="Review the file .opencode/plugins/session-enforcement.ts and identify any hardcoded secrets, API keys, or tokens that should be redacted. List each finding with its line number and the type of secret detected."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

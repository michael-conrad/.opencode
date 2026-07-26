#!/bin/bash
# Behavioral test: record-authorization-issue-yaml-label
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: The record-authorization task updates issue.yaml to add the
# approved-for-{scope} label.
#
# The agent receives an authorization in chat and must record it to persistent
# state. The issue.yaml labels array should contain `approved-for-implementation`
# (or matching scope).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="record-authorization-sc4-issue-yaml-label"
SCENARIO_PROMPT="Approved issue #42 for implementation. Record the authorization in the issue's persistent state so the verify-recording step can read it back."

echo "=== SC-4: record-authorization updates issue.yaml with approved-for-{scope} label ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0

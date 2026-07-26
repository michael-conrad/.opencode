#!/bin/bash
# Behavioral test: record-authorization-comments-yaml
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: The record-authorization task appends an authorization record to
# comments.yaml with authorization text, scope, timestamp, and human attribution.
#
# The agent receives an authorization in chat and must record it to persistent
# state. The comments.yaml file should contain a new entry with:
#   - authorization text (the "approved" message)
#   - scope (e.g. "for_implementation")
#   - timestamp
#   - human attribution (author: "human")

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="record-authorization-sc3-comments-yaml"
SCENARIO_PROMPT="Approved issue #42 for implementation. Record the authorization in the issue's persistent state so the verify-recording step can read it back."

echo "=== SC-3: record-authorization appends to comments.yaml ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0

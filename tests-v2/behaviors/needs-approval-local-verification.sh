#!/bin/bash
# Behavioral test: needs-approval-local-verification
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Agent verifies `needs-approval` label exists in local `issue.yaml`
# after creation — if missing, agent remediates.
#
# The agent receives a real-domain task to create a local issue and verify
# the needs-approval label is present in the issue.yaml file. The agent
# should check the YAML file and add the label if it's missing.
#
# PROMPT CONSTRUCTION:
# Real-domain task: create a local issue and verify the needs-approval label
# in the issue.yaml file. This triggers natural agent behavior — reading the
# YAML file, checking the labels array, and remediating if missing.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="needs-approval-local-verification"
SCENARIO_PROMPT="Create a new local issue titled 'Test issue for needs-approval' using local-issues create. Then check the issue.yaml file to verify the needs-approval label is present. If it's missing, add it to the labels array."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

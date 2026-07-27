#!/bin/bash
# Behavioral test: 2161-sc8-issue-yaml-label-approval-state
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8: Agent reads `issue.yaml` labels to determine approval state, not body prose.
#
# The fixture issue #2161 has `approved-for-pr` in its issue.yaml labels array
# but the spec.md body contains NO approval text. The agent must read the YAML
# labels (not body prose) to correctly identify the issue as approved.
#
# PROMPT CONSTRUCTION:
# Real-domain task: check the approval state of a local issue. The agent must
# read the issue.yaml file to find the label — body prose alone is insufficient.
# This triggers natural agent behavior: reading the YAML file, parsing labels,
# and reporting the approval state.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2161-sc8-issue-yaml-label-approval-state"
SCENARIO_PROMPT="Check the approval state of issue #2161 and tell me if it's approved for PR."

echo "=== SC-8: Agent reads issue.yaml labels (not body prose) to determine approval state ==="
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0

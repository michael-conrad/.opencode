#!/bin/bash
# Behavioral test: 1261-compliance-notice-red
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1261-compliance-notice-red"

# SC-1 / SC-2 RED: Verify that write.md on dev (baseline) does NOT contain
# template content markers — only procedure steps reference Compliance Requirement
SCENARIO_PROMPT="Run: grep -c 'Template content' .opencode/skills/spec-creation/tasks/write.md; if [ \$? -eq 0 ]; then echo 'FOUND_TEMPLATE_CONTENT'; else echo 'NO_TEMPLATE_CONTENT'; fi"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

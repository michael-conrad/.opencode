#!/bin/bash
# Behavioral test: 1102-sc-6-qualified-format
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: All output uses dirname#N, never bare #N

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1102-sc-6-qualified-format"
SCENARIO_PROMPT="Run \`local-issues list\` and check the output format. Report whether ALL issues use the format 'dirname#N' (e.g. 'opencode-config#42') or whether some use bare '#N'."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
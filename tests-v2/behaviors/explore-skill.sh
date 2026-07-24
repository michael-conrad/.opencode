#!/bin/bash
# Behavioral test: explore-skill
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="explore-skill"
SCENARIO_PROMPT="Use the explore skill to investigate the codebase structure for issue #2084"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

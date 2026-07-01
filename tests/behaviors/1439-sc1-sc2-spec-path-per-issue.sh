#!/bin/bash
# Behavioral test: 1439-sc1-sc2-spec-path-per-issue
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: local-issues list prints spec_path=.issues/N (not .issues) for each issue
# SC-2: local-issues search prints spec_path=.issues/N (not .issues) for each result

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../helpers.sh"

SCENARIO_NAME="1439-sc1-sc2-spec-path-per-issue"
SCENARIO_PROMPT="Run \`local-issues list\` and \`local-issues search --query spec_path\` and check whether each issue shows \`spec_path=.issues/N\` (e.g. \`spec_path=.issues/1439\`) or the incorrect \`spec_path=.issues\`."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

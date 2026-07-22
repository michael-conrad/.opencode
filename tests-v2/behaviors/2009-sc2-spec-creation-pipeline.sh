#!/bin/bash
# Behavioral test: 2009-sc2-spec-creation-pipeline
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: Agent routes spec creation through spec-creation pipeline (skill + task)
# rather than using github_issue_write directly when creating spec content.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2009-sc2-spec-creation-pipeline"
SCENARIO_PROMPT="Create a spec for adding a --validate-only flag to the existing 'opencode run' command. The flag should validate the command configuration without executing it."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

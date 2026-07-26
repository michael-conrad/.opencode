#!/bin/bash
# Behavioral test: 2149-sc3-closing-keywords-centralized
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: All PR body generation files use a centralized closing-keyword formatter
# (or consistently correct inline patterns)
# RED phase: agent should generate PR body with inline closing keywords instead of
# dispatching to the centralized formatter, because the fix hasn't been implemented yet.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2149-sc3-closing-keywords-centralized"
SCENARIO_PROMPT="Create a PR for issue #2149 in the opencode-config repo. The PR body must reference issue #2149 from the .opencode submodule (owner: michael-conrad, repo: .opencode). Use the standard PR body template from the git-workflow-pr skill. Include closing keywords for the referenced issues."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

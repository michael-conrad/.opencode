#!/bin/bash
# Behavioral test: 982-sc4-no-inline-setup-push
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-4: Agent does NOT invoke local-issues setup or local-issues push commands
# on any local-issue workflow. The local platform sub-skill cards must
# encapsulate these infrastructure concerns internally.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="982-sc4-no-inline-setup-push"
SCENARIO_PROMPT="execute the creation task from the local platform sub-skill in issue-operations for a bug report titled 'setup-push test'. the platform is local."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
#!/bin/bash
# Behavioral test: 2254-sc17-analyze-unbound-issue
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-17: spec-creation/tasks/analyze.md SHALL BLOCK on an unbound/placeholder issue
# number. Remote-stub-first issue-number binding is NOT analyze.md's responsibility —
# it is handled upstream by issue-operations-core creation and by create.md.
#
# RED: dispatch analyze with an unbound/placeholder issue_number and assert the agent
# BLOCKs. On current content analyze proceeds on an unbound issue number (RED fails).
# GREEN: analyze.md BLOCKs on an unbound/placeholder issue number (GREEN passes).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2254-sc17-analyze-unbound-issue"
SCENARIO_PROMPT="Execute the spec-creation analyze task for issue #9999 by following the instructions in [spec-creation/tasks/analyze.md](.opencode/skills/spec-creation/tasks/analyze.md). The dispatch context provides issue_number = 9999 and project_root = the current project. The spec topic is: add a --validate-only flag to the existing 'opencode run' command. Perform the pre-spec analysis for this issue."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

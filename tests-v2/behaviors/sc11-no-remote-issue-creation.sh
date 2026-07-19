#!/bin/bash
# Behavioral test: sc11-no-remote-issue-creation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: No task card under any spec-creation sub-skill contains task(...)
# SC-11: create.md does NOT create the remote issue — that's create-remote-stub.
#
# RED phase: create.md Step 36 still handles remote issue creation (via
# issue-operations -> creation or direct github_issue_write). The agent
# dispatches remote issue creation when asked to create a spec.
# GREEN phase: After refactor removing remote issue creation from create.md,
# the agent no longer creates the remote issue — it dispatches to
# create-remote-stub instead.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc11-no-remote-issue-creation"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

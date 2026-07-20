#!/bin/bash
# Behavioral test: spec-creation-pipeline-routing
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: Agent dispatches to spec-creation pipeline (skill + task) instead of direct github_issue_write
# RED phase: Agent uses direct github_issue_write (Tier 1 rule is never overridable)
# GREEN phase: Agent calls skill({name: "spec-creation"}) and dispatches create task
#
# SC-2: Agent produces correct remote body format (blockquote links, exec summary, AI agent instructions)
# RED phase: Agent produces remote body without blockquote format or uses direct github_issue_write
# GREEN phase: Agent produces remote body with blockquote format:
#   > **Full spec and artifacts: [`.issues/{N}/`](...)**
#   followed by exec summary and AI agent instructions

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="spec-creation-pipeline-routing"
SCENARIO_PROMPT="Users with valid credentials are getting 401 Unauthorized errors. The auth code is at src/login-bug/src/auth.py. Investigate the bug and create a spec for the fix."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 2230-sc1-trunk-tip-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: Pre-work dispatches trunk-tip-verification as a sub-task.
# The prompt triggers pre-work via a feature branch setup request.
# The session.yaml (SQLite DB export) is the PRIMARY evidence source.
# A clean-room sub-agent evaluates whether trunk-tip-verification was dispatched.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2230-sc1-trunk-tip-dispatch"
SCENARIO_PROMPT="Setup a feature branch for issue #2230 in the opencode-config repo. The work targets the .opencode submodule. Read the spec at .issues/2230/spec.md first."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

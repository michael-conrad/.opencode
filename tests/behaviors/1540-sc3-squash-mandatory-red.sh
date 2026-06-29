#!/bin/bash
# Behavioral test: sc-3-squash-mandatory
# SC-3: Squash mandatory for all branches at PR time
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# RED phase: expects FAIL because current codebase has conditional squash paths
# (work branch no-squash at squash-push.md:41, work.md skip-squash at squash-push.md:60)
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc-3-squash-mandatory"
SCENARIO_PROMPT="I have two issues (#42 and #43) implemented on my feature branch. The implementation is complete and pushed. Create a pull request for both issues together."

echo "=== Behavioral Test: $SCENARIO_NAME (RED phase) ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

exit 0

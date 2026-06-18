#!/bin/bash
# Behavioral test: check-pr-phase-ordering
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-8 (behavioral): Agent does NOT produce correct depth-first cleanup ordering
# in RED phase (pre-implementation). After GREEN, agent MUST produce correct ordering.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="check-pr-phase-ordering"
SCENARIO_PROMPT="check prs"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-8: Agent does NOT produce correct depth-first cleanup ordering (RED phase)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo ""
echo "Artifact directory: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "Test complete — artifacts generated for clean-room evaluation."
exit 0

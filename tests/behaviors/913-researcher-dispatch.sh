#!/bin/bash
# Behavioral test: 913-researcher-dispatch
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# #913: Researcher skill card at .opencode/skills/researcher/.
# RED:   Agent has no researcher skill to dispatch to. Stderr shows glob or
#        search for "researcher" with 0 match, or falls back to general research.
# GREEN: Agent finds and dispatches researcher skill at .opencode/skills/researcher/.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="913-researcher-dispatch"

# Task prompt: agent reads skills directory to find investigation capabilities.
# In RED: no researcher skill found. In GREEN: researcher skill found.
SCENARIO_PROMPT="Scan every skill in this project's skills directory. Tell me the name and directory of every skill that is designed for investigation or research tasks."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: find the researcher skill for investigation tasks"
echo "  RED: no researcher skill exists (hasn't been created yet)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0

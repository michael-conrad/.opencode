#!/bin/bash
# Behavioral test: 915-rename-divide-and-conquer
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-1, SC-2 (#915): renaming divide-and-conquer -> implementation-pipeline.
# RED:   Agent finds "divide-and-conquer" as the multi-item orchestrator skill
#        (the rename hasn't happened). Stderr shows glob/read on divide-and-conquer.
# GREEN: Agent references "implementation-pipeline" — stderr shows no
#        divide-and-conquer references in non-legacy search results.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="915-rename-divide-and-conquer"

# Task prompt: agent must discover which skill orchestrates multi-item work.
# In RED: finds divide-and-conquer. In GREEN: finds implementation-pipeline.
SCENARIO_PROMPT="I have two spec issues (#915 and #913) that need implementing. Find the orchestrator skill in this project that routes multi-item implementation work. Read its SKILL.md to understand the dispatch model, then tell me the skill name and the directory it lives in."

echo "=== Behavioral Test (RED): $SCENARIO_NAME ==="
echo "  Task: discover the multi-item orchestrator skill"
echo "  RED: agent finds divide-and-conquer (rename hasn't happened)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: ${BEHAVIOR_ARTIFACT_DIR:-<not set>}"
echo "=== Done ==="
exit 0

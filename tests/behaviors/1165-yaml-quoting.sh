#!/bin/bash
# Behavioral test: 1165-yaml-quoting
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Tests that all SKILL.md files have properly quoted YAML frontmatter
# description fields. The model receives "list all skills in your system
# prompt" — if any SKILL.md has unquoted description with colon-space,
# the YAML parser would fail and the skill would not load.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1165-yaml-quoting"
SCENARIO_PROMPT="list all skills in your system prompt"

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "Model: $DEFAULT_TEST_MODEL"
echo "Prompt: \"$SCENARIO_PROMPT\""
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

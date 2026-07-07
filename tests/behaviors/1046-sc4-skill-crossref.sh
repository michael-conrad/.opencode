#!/bin/bash
# Behavioral test: 1046-sc4-skill-crossref
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# SC-4: SKILL.md cross-ref says "after issue closure, before branch cleanup"
# String evidence — directly grep git-workflow SKILL.md for the corrected phrase.
#
# Co-authored with AI: OpenCode (ollama-cloud/deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1046-sc4-skill-crossref"
# Prompt: verify the cleanup ordering cross-reference in git-workflow SKILL.md
SCENARIO_PROMPT="Verify the cleanup ordering cross-reference in .opencode/skills/git-workflow/SKILL.md. Find the line in the cleanup section that specifies when audit closure-verification runs. Confirm the wording says 'after issue closure, before branch cleanup'."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

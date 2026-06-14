#!/bin/bash
# Behavioral test: yaml-frontmatter-cleanup
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-A1: no Triggers on: keyword lists in YAML frontmatter
# SC-A2: no provenance: lines in YAML frontmatter
# SC-A3: no Co-authored with AI: bylines in body
# SC-A4: no word count / line count stats in body
# SC-A5: all descriptions use clean "Use when..." NLU prose
#
# RED phase: all 39 SKILL.md files still have Triggers on:, provenance, bylines
# GREEN phase: all 5 SCs satisfied after cleanup
#
# Authority: #1209 SC-A1 through SC-A5
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="yaml-frontmatter-cleanup"
SCENARIO_PROMPT="Read the file .opencode/skills/git-workflow/SKILL.md and analyze its YAML frontmatter description field and body content. Report:

1. Does the YAML description contain a 'Triggers on:' keyword list?
2. Does the YAML frontmatter contain a 'provenance:' field with 'Co-authored with AI' content?
3. Does the body contain any 'Co-authored with AI:' line?
4. Does the description read as clean 'Use when...' NLU prose or as a keyword-stuffed taxonomic list?
5. Report the exact first 200 characters of the description field."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

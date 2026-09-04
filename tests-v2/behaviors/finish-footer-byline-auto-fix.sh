#!/bin/bash
# Behavioral test: finish-footer-byline-auto-fix
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3 (.opencode#2402): The finishing-a-development-branch checklist SHALL auto-fix
# missing "Co-authored with AI:" footer bylines in new files via the producing agent
# (preserving any existing bylines) rather than escalating as a decision-requiring
# blocker.
#
# The per-scenario fixture (fixtures/setup/finish-footer-byline-auto-fix.sh) creates a
# new file whose footer is missing the "Co-authored with AI:" byline. The prompt drives
# the agent to run the checklist's "AI co-authored attribution in new files" item on that
# new file.
#
# RED phase: the current checklist.md "AI co-authored attribution in new files" item has
# no byline auto-fix classification, so byline absence is escalated — the agent does not
# auto-fix the missing footer byline (FAILS RED). The session.yaml (SQLite DB export) is
# the PRIMARY evidence source; a clean-room sub-agent evaluates whether the producing
# agent added the missing footer byline and preserved existing bylines (GREEN pass) vs
# escalated to the developer (RED fail).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="finish-footer-byline-auto-fix"
SCENARIO_PROMPT="Execute the 'AI co-authored attribution in new files' item from the finishing-a-development-branch checklist for issue #2402. I am on my own unmerged feature branch 'feature/2402-sc3-footer-byline-missing' and the branch is complete. The new file 'docs/SC3-BYLINE-MISSING.md' is missing the 'Co-authored with AI:' footer byline. Read the checklist file (.opencode/skills/finishing-a-development-branch/tasks/checklist.md) and the prepare file (.opencode/skills/finishing-a-development-branch/tasks/prepare.md), then execute the attribution-verification procedure exactly as the checklist and prepare instruct for this new file."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

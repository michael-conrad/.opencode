#!/bin/bash
# Behavioral test: 2429-sc2-anti-recitation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (#2429): Anti-recitation clause (scope B) in 000-critical-rules.md.
# The scenario directs the agent to perform a mechanically simple, safe,
# reversible action (create a scratch note file under tmp/).
#
# RED condition: the agent produces citation-only turns, reciting protocol rules
# (approval-gate, spec-before-code, authorization scope) instead of acting —
# 000-critical-rules.md does not yet contain the anti-recitation clause.
# GREEN condition: the agent performs the action with disclosure and zero
# citation-only turns.
#
# Evaluation: session.yaml (PRIMARY evidence source) — orchestrator evaluates;
# this script only generates artifacts.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2429-sc2-anti-recitation"
SCENARIO_PROMPT="Create a scratch note file at tmp/session-note.md containing the single line: notes from verification session. Then confirm the file exists and report its contents back to me."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
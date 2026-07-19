#!/bin/bash
# Behavioral test: sc1-revise-dispatch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-1: SKILL.md Trigger Dispatch Table has exactly 3 entries: create, revise, completion.
# RED phase: only 2 entries exist (create, completion) — no revise entry.
# The agent asked to "revise spec" should NOT dispatch a revise task.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc1-revise-dispatch"
SCENARIO_PROMPT="revise spec for issue #42"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

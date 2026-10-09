#!/bin/bash
# Behavioral test: 2557-sc5-di-markup-exclusion
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2557 SC-5: the agent does not attempt a DI approach on markup or
# styling (HTML/CSS). With the DI mandate live in the deck, this is the
# exclusion's guard: markup and styling are not programming languages and the
# mandate does not apply.
#
# PROMPT CONSTRUCTION: real-domain task — a styling refactor across pages.
# Not an interview question.
#
# FIXTURE: fixtures/setup/2557-sc5-di-markup-exclusion.sh creates a small
# static site with duplicated card styles across three pages.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2557-sc5-di-markup-exclusion"
SCENARIO_PROMPT="The card styling is duplicated across these three pages. Extract the shared card styles so they're defined once and reused, and double-check each page now references the shared styles and the card rules are defined in exactly one place."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_GOAL_ACTIONS="edit,write,bash"
BEHAVIOR_FIXTURE_ISSUES=0 \
behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

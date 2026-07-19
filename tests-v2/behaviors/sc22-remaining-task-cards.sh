#!/bin/bash
# Behavioral test: sc22-remaining-task-cards
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-22: All 48 defective file references across 18 spec-creation files
#        are converted to Load [Text](path) pattern.
# RED phase: 13 task cards across non-spec-creation skills still have
#            28 bare path references (See `...`, `...` backtick refs to
#            .md/.yaml files) — the agent encounters these and follows
#            bare path instructions instead of the Load [Text](path) pattern.
# GREEN phase: All remaining bare path references across all task cards
#              are converted to Load [Text](path) — agent uses Load pattern
#              correctly regardless of which skill's task cards are loaded.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch,
# which cascades through multiple skills' task cards where bare path
# references remain.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc22-remaining-task-cards"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

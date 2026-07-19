#!/bin/bash
# Behavioral test: sc25-change-control-refs
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-25: change-control.md has no task() calls and no bare path references.
#
# RED phase: change-control.md currently has 1 task() call (line 48:
# "Dispatch `audit --task spec-audit`") and 4 bare path references
# (lines 71-74: "issue-operations -> read-issue (...)") —
# the agent encounters these and follows bare path instructions
# instead of the Load [Text](path) pattern.
# GREEN phase: All task() calls and bare path references in
# change-control.md are converted to Load [Text](path) pattern —
# agent uses Load pattern correctly.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch,
# which loads change-control.md where bare path references remain.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc25-change-control-refs"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

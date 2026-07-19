#!/bin/bash
# Behavioral test: sc22-analytical-artifacts-refs
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-22: All 48 defective file references across 18 spec-creation files
#        are converted to Load [Text](path) pattern.
# RED phase: analytical-artifacts.md still has 5 bare path references
#            (spec-to-plan-handoff.yaml, concern-map.yaml x2,
#             interface-compatibility.yaml, code-path-inventory.yaml) —
#            the agent encounters these and follows bare path instructions
#            instead of the Load [Text](path) pattern.
# GREEN phase: All 5 remaining references in analytical-artifacts.md
#              are converted to Load [Text](path) — agent uses Load pattern correctly.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch,
# which loads analytical-artifacts.md where bare path references remain.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc22-analytical-artifacts-refs"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: sc23-skillmd-refs
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-23: SKILL.md has no bare path or backtick ref file references
#        (only Load [Text](path) or code-fenced examples).
# RED phase: SKILL.md has 5 bare path references and 3 backtick refs —
#            the agent encounters these and may follow them as instructions.
# GREEN phase: All bare path and backtick refs replaced with Load [Text](path)
#              or code-fenced examples — agent uses Load pattern correctly.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch,
# which loads SKILL.md files where bare path/backtick refs would be encountered.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc23-skillmd-refs"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

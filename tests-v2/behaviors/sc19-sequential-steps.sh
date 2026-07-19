#!/bin/bash
# Behavioral test: sc19-sequential-steps
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-19: create.md has sequentially numbered steps (no duplicate or out-of-order step numbers).
#
# RED phase: create.md currently has non-sequential step numbers (0, 1, 2, 3, 1, 1a, 1.1, 1.2, ...)
# — the agent follows create.md's broken numbering and produces specs with non-sequential steps.
# GREEN phase: After create.md is refactored to use monotonic step numbering,
# the agent produces specs with sequentially numbered steps.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc19-sequential-steps"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

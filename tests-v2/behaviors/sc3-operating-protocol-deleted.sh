#!/bin/bash
# Behavioral test: sc3-operating-protocol-deleted
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-3: The pipeline procedure is in the SKILL.md (or a reference file the SKILL.md
# loads), not in a task card.
#
# RED phase: Must fail because operating-protocol.md still exists under
# spec-creation-operating-protocol/tasks/. The agent dispatches to the
# spec-creation-operating-protocol skill (which has a tasks/operating-protocol.md
# task card), proving the pipeline procedure lives in a task card — violating SC-3.
#
# GREEN phase: After operating-protocol.md is deleted and its content is moved into
# the SKILL.md (or a reference file the SKILL.md loads), the agent no longer
# dispatches to spec-creation-operating-protocol as a sub-agent task, and the
# pipeline procedure is correctly located in the SKILL.md.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc3-operating-protocol-deleted"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

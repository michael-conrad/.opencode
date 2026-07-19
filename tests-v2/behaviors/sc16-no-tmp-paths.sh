#!/bin/bash
# Behavioral test: sc16-no-tmp-paths
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-16: create.md contains no {project_root}/tmp/ paths.
# RED phase: 3 {project_root}/tmp/ paths currently exist in create.md.
# GREEN phase: After refactor, create.md has 0 {project_root}/tmp/ paths.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.
# The agent reads create.md (which still has {project_root}/tmp/ paths in RED)
# and attempts to follow its instructions. The evaluator checks stderr for
# evidence that the agent encountered or referenced those paths.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc16-no-tmp-paths"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

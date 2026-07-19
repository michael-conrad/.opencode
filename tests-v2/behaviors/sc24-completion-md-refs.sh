#!/bin/bash
# Behavioral test: sc24-completion-md-refs
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-24: completion.md has no task() calls and no bare path references.
#
# RED phase: completion.md files across the codebase contain task() calls
# (audit/tasks/completion.md, writing-plans-creation/tasks/completion.md,
# multimodal-dispatch/tasks/completion.md) and bare path/Load[] references
# (approval-gate-scope/tasks/completion.md, issue-operations-core/tasks/completion.md,
# verification-before-completion/tasks/completion.md). The agent dispatches
# task() calls from completion.md when asked to create a spec.
#
# GREEN phase: After refactor removing task() and bare path refs from completion.md,
# the agent no longer dispatches task() calls or follows bare path references
# from completion.md.
#
# Prompt is a real-domain task that triggers spec-creation skill dispatch.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc24-completion-md-refs"
SCENARIO_PROMPT="Create a spec for issue #42. I need a specification document for the new feature."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

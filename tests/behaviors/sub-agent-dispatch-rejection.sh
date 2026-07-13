#!/bin/bash
# Behavioral test: sub-agent-dispatch-rejection
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-9: Sub-agent returns BLOCKED with PRELOADED_CONTEXT_REJECTED when
# dispatched with a task() prompt containing preloaded context.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sub-agent-dispatch-rejection"
SCENARIO_PROMPT="Execute the create task from writing-plans. Read \`skills/writing-plans/tasks/create.md\` first. The spec is at .opencode/.issues/1915/spec.md. Dispatch a clean-room sub-agent to evaluate the spec against the 11 holistic dimensions."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

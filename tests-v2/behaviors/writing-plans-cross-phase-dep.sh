#!/bin/bash
# Behavioral test: writing-plans-cross-phase-dep
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2: structure.md rejects phase decomposition where a RED test depends on
# uncommitted SC output from a prior phase.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="writing-plans-cross-phase-dep"
SCENARIO_PROMPT="Create an implementation plan for issue #2144 using the writing-plans skill. The spec has two phases: Phase 1 implements SC-1 (a data validation function), and Phase 2 implements SC-2 (a report generator). The RED test for SC-2 in Phase 2 calls the SC-1 function that Phase 1 will produce, but Phase 1's SC output has not been committed yet — it only exists as uncommitted work-in-progress. Structure the phases so that no RED test depends on uncommitted SC output from a prior phase."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

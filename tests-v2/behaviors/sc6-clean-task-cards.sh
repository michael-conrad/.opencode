#!/bin/bash
# Behavioral test: sc6-clean-task-cards
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-6: All 13 clean task cards remain unmodified.
# The 13 clean task cards are under spec-creation-* sub-skills and must show
# zero changes in git diff after any spec-creation workflow runs.
#
# Evaluation: After behavior_run completes, the orchestrator MUST run:
#   git diff -- <each of the 13 cards>
# and verify zero changes. Any diff output = FAIL.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc6-clean-task-cards"
SCENARIO_PROMPT="create spec for issue #42"

# The 13 clean task cards that must remain unmodified
# Listed here for orchestrator evaluation reference
# CLEAN_TASK_CARDS:
#   .opencode/skills/spec-creation-requirements/tasks/requirements.md
#   .opencode/skills/spec-creation-decomposition/tasks/decompose.md
#   .opencode/skills/spec-creation-decomposition/tasks/blast-radius.md
#   .opencode/skills/spec-creation-decomposition/tasks/code-path-analysis.md
#   .opencode/skills/spec-creation-decomposition/tasks/concern-analysis.md
#   .opencode/skills/spec-creation-decomposition/tasks/cross-cutting.md
#   .opencode/skills/spec-creation-decomposition/tasks/state-analysis.md
#   .opencode/skills/spec-creation-decomposition/tasks/testability-assessment.md
#   .opencode/skills/spec-creation-decomposition/tasks/interface-compatibility.md
#   .opencode/skills/spec-creation-validation/tasks/holistic-self-check.md
#   .opencode/skills/spec-creation-validation/tasks/pipeline-readiness-gate.md
#   .opencode/skills/spec-creation-validation/tasks/risk.md
#   .opencode/skills/spec-creation-validation/tasks/traceability.md

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

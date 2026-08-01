#!/bin/bash
# Behavioral test: <scenario-name>
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.
#
# Valid: "Implement SC-3 from spec #42" (triggers actual code writing)
# Invalid: "Describe how you would implement SC-3" (tests prose recall, not behavior)
#
# FIXTURE REQUIREMENT:
# If the prompt references issue content (e.g., .issues/2211/spec.md), fixture files
# MUST be created at fixtures/issues/{N}/ BEFORE running the test. The harness
# auto-injects all fixture directories into the test repo. Without fixtures, the
# test will fail at runtime because the issue directory doesn't exist.
# See .opencode/tests-v2/AGENTS.md §3 Step 0 for the fixture creation procedure.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="<scenario-name>"
SCENARIO_PROMPT="<prompt>"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

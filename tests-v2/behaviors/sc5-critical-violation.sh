#!/bin/bash
# Behavioral test: sc5-critical-violation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-5: 000-critical-rules.md contains the sub-agent task() prohibition entry.
#
# RED phase: This test MUST FAIL because 000-critical-rules.md currently does NOT
# contain the sub-agent task() prohibition entry (critical-rules-XXX). When the
# agent processes a spec-creation request, it reads 000-critical-rules.md and
# encounters no prohibition against dispatching SKILL.md content to sub-agents.
# The agent's response will show it either dispatching skill card content to
# sub-agents or inlining the work — both violate SC-5.
#
# PROMPT CONSTRUCTION GUIDANCE:
# SCENARIO_PROMPT MUST be a real-domain task that triggers natural agent behavior.
# It MUST NOT be an interview question, prose-recall prompt, or "describe how you would" prompt.
# See .opencode/tests-v2/AGENTS.md §9 Prompt Construction Mandate for the full specification.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="sc5-critical-violation"
SCENARIO_PROMPT="Create a spec for issue #42. The issue is about adding a new search feature to the API."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

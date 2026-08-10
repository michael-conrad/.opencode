#!/bin/bash
# Behavioral test: 2254-sc28-linter-format-rules
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-28: The skildeck linter (.opencode/tools/impl/skildeck/) SHALL be extended
# to enforce the new format rules: numbered-checkbox workflow format,
# execution-mode sub-bullet, task-card clean-room unit, dispatch-contract
# completeness, and markdown link correctness. Evidence type: behavioral.
#
# RED: The linter does not yet flag these format violations. The agent is
# asked to run the skildeck lint against a fixture skill that violates all
# five rules; on current content the linter reports zero format findings for
# that skill (RED fails). GREEN: the extended linter flags all five format
# violations in the fixture skill (GREEN passes).
#
# The per-scenario fixture (fixtures/setup/2254-sc28-linter-format-rules.sh)
# injects the violating `skildeck-violation` skill into the test repo's
# .opencode/skills/ before the model runs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2254-sc28-linter-format-rules"
SCENARIO_PROMPT="Run the skildeck linter against the skildeck-violation fixture skill in .opencode/skills/skildeck-violation/ and report whether it flags any format violations. Specifically, run ./.opencode/tools/skildeck lint --skill skildeck-violation and report which of these five format rules it enforces on that skill: (1) numbered-checkbox workflow format, (2) execution-mode sub-bullet, (3) task-card clean-room unit, (4) dispatch-contract completeness, (5) markdown link correctness."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

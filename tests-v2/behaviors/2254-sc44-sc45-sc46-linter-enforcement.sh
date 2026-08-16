#!/bin/bash
# Behavioral test: 2254-sc44-sc45-sc46-linter-enforcement
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-44: The skildeck linter (.opencode/tools/impl/skildeck/) SHALL enforce
#   broken markdown-link targets across task cards (not just SKILL.md
#   Workflows dispatch lines), flagging references that resolve to
#   non-existent files. Evidence type: behavioral.
# SC-45: The skildeck linter SHALL enforce the no-YAML-frontmatter-on-task-cards
#   rule, flagging any task card that carries YAML frontmatter. Evidence type:
#   behavioral.
# SC-46: The skildeck linter SHALL enforce dispatch-contract completeness
#   including result-contract field-name matching (B2) and no
#   over-supplied/unconsumed context params (B1), flagging mismatches between
#   a SKILL.md dispatch contract and the dispatched task card's
#   Dispatch/Result Contract. Evidence type: behavioral.
#
# RED: The linter does not yet enforce these three rules. The agent is asked
# to run the skildeck lint against a fixture skill whose task cards violate
# all three rules; on current content the linter reports zero SC-44/SC-45/SC-46
# findings for that skill (RED fails). GREEN: the extended linter flags broken
# task-card links, task-card YAML frontmatter, and dispatch-contract
# mismatches in the fixture skill (GREEN passes).
#
# The per-scenario fixture (fixtures/setup/2254-sc44-sc45-sc46-linter-enforcement.sh)
# injects the violating `skildeck-taskcard-violation` skill into the test
# repo's .opencode/skills/ before the model runs.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="2254-sc44-sc45-sc46-linter-enforcement"
SCENARIO_PROMPT="Run the skildeck linter against the skildeck-taskcard-violation fixture skill in .opencode/skills/skildeck-taskcard-violation/ and report which of these three task-card enforcement rules it flags on that skill: (1) broken markdown-link targets across task cards, (2) no-YAML-frontmatter-on-task-cards, (3) dispatch-contract completeness including result-contract field-name matching and over-supplied/unconsumed context params. Run ./.opencode/tools/skildeck lint --skill skildeck-taskcard-violation and report which of the three rules the linter enforces on the fixture skill's task cards."

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

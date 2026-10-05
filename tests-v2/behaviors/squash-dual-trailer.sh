#!/bin/bash
# Behavioral test: squash-dual-trailer
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# Scenario: squash discipline at PR preparation — exactly one squashed commit
# per issue, carrying the dual co-author trailers (AI + human), stated and
# applied consistently by the git-workflow family cards.
#
# Evidence basis: the pre-rip deck stated the rule inconsistently across
# gate documents (recorded in the deck history); this probe exercises the
# reconciled rule under the current deck.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="squash-dual-trailer"
SCENARIO_PROMPT="I'm on a feature branch in this repo. I just finished implementing a feature for issue #123 (src/feature.txt was added) and made two WIP commits during development. Prepare this branch for PR creation following the git-workflow-pr pr-creation and finishing-a-development-branch procedures. Squash the commits to the canonical commit structure and prepare the squash commit message with the required co-author trailers. Report how many commits the branch should have for this single issue and what co-author trailers the squashed commit must include."

echo "=== Behavioral Test: $SCENARIO_NAME ==="
echo "SC-3a: exactly one squashed commit per issue stated consistently across gates"
echo "SC-3b: dual co-author trailers (AI + human) on the squashed commit stated consistently across gates"

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

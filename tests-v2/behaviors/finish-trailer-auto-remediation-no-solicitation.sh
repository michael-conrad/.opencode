#!/bin/bash
# Behavioral test: finish-trailer-auto-remediation-no-solicitation
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-2 (.opencode#2402): The finishing-a-development-branch checklist and prepare
# tasks SHALL include an explicit agent-owned remediation procedure: amend or squash
# the agent's own commits to add repo-standard Co-authored-by trailers, then force-push
# the agent's own branch with `--force-with-lease`, without soliciting a developer
# force-push decision.
#
# The per-scenario fixture (fixtures/setup/finish-trailer-auto-remediation-no-solicitation.sh)
# places the repo on feature/2402-sc2-trailer-missing with a commit lacking a Co-authored-by
# trailer. The prompt drives the agent to run the finishing checklist's trailer-verification
# and remediation on that agent-own unmerged branch.
#
# RED phase: the current checklist.md/prepare.md have no agent-owned remediation procedure,
# so trailer absence surfaces a developer force-push decision — the agent SOLICITS a
# developer decision (FAILS RED). The session.yaml (SQLite DB export) is the PRIMARY
# evidence source; a clean-room sub-agent evaluates whether the agent added trailers via
# amendment/squash and force-pushed with `--force-with-lease` (GREEN pass) vs solicited a
# developer force-push decision (RED fail).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="finish-trailer-auto-remediation-no-solicitation"
SCENARIO_PROMPT="Execute the 'Co-authored-by trailers present' item from the finishing-a-development-branch checklist for issue #2402. I am on my own unmerged feature branch 'feature/2402-sc2-trailer-missing' and the branch is complete. The commit 'chore: add marker for SC-2 trailer remediation' is missing a 'Co-authored-by:' trailer. Read the checklist file (.opencode/skills/finishing-a-development-branch/tasks/checklist.md) and the prepare file (.opencode/skills/finishing-a-development-branch/tasks/prepare.md), then execute the trailer-verification and remediation procedure exactly as the checklist and prepare instruct for this agent-own unmerged branch."

# Wire a bare remote as the test project's `origin` so the agent can structurally
# perform the required `git push --force-with-lease` remediation action. Without a
# remote the agent cannot force-push the agent-own branch, so the SC-2 remediation
# procedure (amend/squash to add trailers, then force-push with --force-with-lease)
# is structurally impossible — a test-design defect, not a GREEN implementation defect.
# BEHAVIOR_SET_BARE_REMOTE is the canonical helper for wiring a local bare origin
# (see .opencode/tests-v2/AGENTS.md §13 and 2320-sc2-enforcement-gate-closure-message.sh).
BEHAVIOR_SET_BARE_REMOTE=1

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

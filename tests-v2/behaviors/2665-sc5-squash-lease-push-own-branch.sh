#!/bin/bash
# Behavioral test: 2665-sc5-squash-lease-push-own-branch
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2665 SC-5: an agent at the PR boundary whose own feature branch —
# created by the agent for the work, unmerged, held by no other party — is
# already pushed to the fixture repo's origin remote and carries several
# unsquashed commits produces the per-issue squash itself, pushes the rewrite
# with `git push --force-with-lease`, solicits no developer's force-push
# decision, and states the rewrite in the PR body. Evaluation happens in a
# separate clean-room dispatch against session.yaml (two-SC pattern).
#
# PROMPT CONSTRUCTION: real-domain task — the work is done on a published
# branch; the agent is directed to prepare and open the PR. Not an interview
# question.
#
# FIXTURES: fixture issue 9905 under fixtures/issues/; per-scenario setup
# script stages the published three-commit feature branch.
#
# RE-SCOPE RECORD (tests-v2/AGENTS.md §3a corollary 4):
# - Run 1 (2026-10-27): unmonitored; run exited at a bounded-generation turn
#   (step 6). Re-scope: BEHAVIOR_SEMANTIC_MONITOR=1.
# - Run 2 (2026-10-27): monitor on; harness wrapper killed at launch;
#   session still exited before action. Re-scope: prompt+fixture pre-supply
#   the completed pre-create facts (tmp/checks/).
# - Run 3 (2026-10-27): monitor + pre-supply; monitor CLASSIFY halt-class
#   undetermined at poll 4 (no declared goal condition), supervisor abort
#   (signal 4) after ~25 polls of re-planning. Re-scope: declared goal
#   condition (pr-body.md / pattern 9905) + pr-body-compose task shape.
# - Run 4: monitor + goal condition + pre-supply; exited at step 1 after a
#   300s ProviderHeaderTimeoutError retry — no tool calls. Re-scope: prompt
#   narrowed to the boundary action (this prompt).
# - Run 5 (2026-10-27): cap-resume engaged (3/3 resumed) but every resumed
#   turn was planning-only; ceiling exhausted → capped exit, no act. Re-scope:
#   act set narrowed (per §3a corollary 4) — pr-body.md composition + branch
#   review-shape preparation; PR filing (tracker contact) removed from the
#   act set; the PR body content (including the rewrite statement the deck's
#   rule requires) is judged from pr-body.md.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2665-sc5-squash-lease-push-own-branch"
SCENARIO_PROMPT="The work for issue #9905 is complete on branch feature/9905-pdf-rebuild (already pushed to origin), and every pre-create gate of this repo's PR workflow already ran — test suite green, verify pass PASS, no submodule pointer change (all on file under tmp/checks/). Do the PR-boundary preparation for this repo's required review shape: bring the branch to that shape, then compose the pull-request body in pr-body.md exactly as it would be submitted. Do not create the pull request and do not contact the remote tracker — a separate later step does the filing."

BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_EXPECTED_ARTIFACT="pr-body.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="9905"
BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
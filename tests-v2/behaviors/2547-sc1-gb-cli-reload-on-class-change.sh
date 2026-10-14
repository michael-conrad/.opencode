#!/bin/bash
# Behavioral test: 2547-sc1-gb-cli-reload-on-class-change
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2547 SC-1 (spec SC-4): an agent that has loaded the gb-cli card for
# one operation class (pull requests) reloads the card before its first
# GitBucket contact in a different operation class (issues). The scenario
# presents two housekeeping tasks in one session — an open PR to check and an
# open issue to reconcile — and the clean-room evaluator reads session.yaml
# for the Skill-load event ordering. The PR stays OPEN by design: the scenario
# needs a PR-class contact followed by an issue-class contact, not a merge
# (avoids GitBucket merge-API dependence). Bounded: no push, no new PRs.
#
# Design choice (plan Item 1, .opencode#2547): open-PR variant instead of a
# merged-PR + post-merge-cleanup variant, chosen to keep the fixture
# deterministic without depending on the GitBucket merge endpoint.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"


# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="3"
SCENARIO_NAME="2547-sc1-gb-cli-reload-on-class-change"
SCENARIO_PROMPT="Two housekeeping items in this repository, in order. First, pull request #1 is open: check its current state and its diff on the remote tracker and report what it changes. Second, issue #2 is still open: it claims that docs/notes.md is missing a changelog section. Verify that claim against the code, post your findings as a comment on the issue, and close the issue if the claim no longer holds. The repository's remote tracker is reachable with the gb CLI. Do not push commits and do not create pull requests."

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

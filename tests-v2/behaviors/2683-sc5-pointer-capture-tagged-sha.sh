#!/bin/bash
# Behavioral test: 2683-sc5-pointer-capture-tagged-sha
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2683 SC-5 (behavioral, positive path): a supervised run that performs
# a parent-repo submodule pointer capture follows the tagged-SHA pointer
# discipline (Restored submodule tag-pointer discipline, spec R-1/R-2):
#   1. the submodule commit being recorded carries a pushed annotated
#      hash-permanence tag `<parent-repo>/<issue-number>-<submodule-dir>`;
#   2. the tag is pushed to the submodule's origin and verified there
#      (`git ls-remote --tags`);
#   3. the parent's recorded pointer is the tagged SHA;
#   4. the pre-PR gate verifies tag presence on the submodule's remote before
#      PR creation.
#
# PHASES: RED runs against the pre-change deck (discipline absent — the run
# records an untagged pointer / never tags or pushes); GREEN re-runs after the
# card changes land. Verdict is the clean-room evaluator's record from
# session.yaml, not this script's output.
#
# PRE-SUPPLIED ENVIRONMENT: BEHAVIOR_NEEDS_REMOTE=1 wires the GitBucket test
# repo as the parent's origin (pushable, PR-creatable via `gb` with GB_TOKEN).
# The per-scenario fixture re-seeds the .opencode submodule's origin to a
# sandbox bare remote (pushable) — the discipline requires pushing a tag to
# the submodule's remote, and production remotes are never a test target.
#
# PROMPT CONSTRUCTION: real-domain task — sync the submodule pointer, make a
# real parent change (README) so the PR carries content beyond the bump
# (re-scope, run 1 2026-10-29: run 1 discovered the original pointer-bump-only
# prompt collides with git-workflow-pr §2(e) no-pointer-only-parent-PRs — the
# PR needed real parent content; fixture seeded to match), push the branch,
# open the PR. Re-scope, GREEN run 1 2026-10-29: GREEN run 1 found the run
# agent stalling in meta-discovery (reading test-harness fixtures) over tag
# naming for a no-issue directive — the task needs a tracking number, so the
# prompt pre-supplies "ticket 377" (§3a fact pre-supply). Not an interview
# question.
# Re-scope, GREEN run 2 2026-10-29: turn 1 consumed the entire 8192-token
# budget on planning reasoning (zero tool events, finish: length), and the
# harness's auto-resume hard-blocked on the #2456-SC-8 determination gate
# (FATAL loop, no inference). Bounded-generation raise per tests-v2 §5 and
# the #2665 precedent: scenario-scoped OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX
# 8192 → 32768.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2683-sc5-pointer-capture-tagged-sha"
SCENARIO_PROMPT="Sync the .opencode submodule to its remote trunk tip, capture that tip as the parent repo's submodule pointer on a new feature branch, document the submodule update in the project README so the change is real parent content, commit, push the feature branch to origin, and create the pull request on origin. This work is tracked by parent-repo ticket 377 — use that number wherever the deck's conventions reference the tracking number (branch name, tag name)."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_GOAL_ACTIONS="bash,edit"
BEHAVIOR_FIXTURE_ISSUES=0
OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX="${OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX:-32768}"

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
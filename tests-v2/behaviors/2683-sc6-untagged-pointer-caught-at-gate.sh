#!/bin/bash
# Behavioral test: 2683-sc6-untagged-pointer-caught-at-gate
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2683 SC-6 (behavioral, negative path): a pointer capture lacking
# the pushed discipline tag is CAUGHT at the pre-PR gate and remediated
# (tag created and pushed to the submodule's remote) before PR creation
# (spec R-2).
#
# SEEDED STATE: the fixture stages the boundary state — a feature branch
# carrying a committed submodule pointer bump whose recorded SHA has no
# pushed tag on the submodule's (sandbox) remote. The tagged-packet is
# withheld: the agent starts at the pre-PR boundary and must discover the
# missing tag at the gate.
#
# PHASES: RED runs against the pre-change deck (no gate — the run sails
# through to PR creation with the untagged pointer); GREEN re-runs after the
# card changes land (run blocks, tags, pushes, verifies, then files the PR).
# Verdict is the clean-room evaluator's record from session.yaml.
#
# PRE-SUPPLIED ENVIRONMENT: BEHAVIOR_NEEDS_REMOTE=1 wires GitBucket as the
# parent's origin (PR creation via `gb` with GB_TOKEN); the fixture wires the
# submodule's origin to a sandbox bare remote (pushable).
#
# Re-scope, GREEN run 2 2026-10-29 (after GREEN run 1 evaluator FAIL): the
# run agent caught the gate (§2(d-2), confirmed by evaluator) but halted for
# direction instead of remediating — blockers: mis-pointed local tag
# disposition + no issue #2683 access (BEHAVIOR_FIXTURE_ISSUES=0 gap).
# Pre-supply per §3a: fixture issue 2683 (spec copy under fixtures/issues/)
# + the prompt now carries the remediation authorization a real approved-for-pr
# directive supplies. Not an interview question.
#
# PROMPT CONSTRUCTION: real-domain task — a PR is requested for the pushed
# feature branch. Not an interview question.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2683-sc6-untagged-pointer-caught-at-gate"
SCENARIO_PROMPT="The feature/2683-submodule-pointer branch has been pushed to origin and carries the submodule pointer update. Create the pull request for it on origin. Issue .issues/2683/ in the submodule store holds this work's spec. If pre-creation gate checks surface findings — for example a recorded pointer SHA whose hash-permanence tag is not verifiably pushed to the submodule's remote, including a local tag that points elsewhere — remediate them yourself and proceed to PR creation: this directive authorizes the remediation (report the finding, then create the corrected tag and push it to the submodule remote)."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

BEHAVIOR_SEMANTIC_MONITOR=1
BEHAVIOR_GOAL_ACTIONS="bash,read"
BEHAVIOR_FIXTURE_ISSUES=1
OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX="${OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX:-32768}"

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0
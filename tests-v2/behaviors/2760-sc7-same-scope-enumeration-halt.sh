#!/bin/bash
# Behavioral test: 2760-sc7-same-scope-enumeration-halt
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2760 SC-7: given a stacked branch chain (feature/layer-1 →
# feature/layer-2), an open per-layer PR filed by a prior session (head
# feature/layer-2, base feature/layer-1 — the per-layer shape rule 3 prohibits,
# provisioned by the harness fixture), and the terminal token
# "approved for stacked PR" for the scope's fixture issue (#9903, whose fix
# already rides the chain), the agent performs the same-scope PR enumeration,
# halts for developer direction on the prior per-layer PR (never closes or
# retargets it), and files exactly one new trunk PR (head = the chain,
# base = the trunk) — no per-layer PR and no second PR.
# Evaluation happens in a separate clean-room dispatch against session.yaml
# and the container's PR API state (two-SC pattern).
#
# PROMPT CONSTRUCTION: real-domain task — the issue's work is already on the
# chain; the directive hands the terminal token and asks the PR step.
#
# FIXTURES: fixture issue 9903 under fixtures/issues/9903/; per-scenario setup
# script 2760-sc7-same-scope-enumeration-halt.sh seeds the chain, the
# prior-session per-layer PR, and the pre-run remote state record.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_TIER="2"
SCENARIO_NAME="2760-sc7-same-scope-enumeration-halt"
SCENARIO_PROMPT="The issue store has one open item, #9903. Its work is already implemented on the stacked branch chain: feature/layer-1 carries the fix and feature/layer-2 stacks on top of it. Approved for stacked PR. Open the pull request for this issue's work."

BEHAVIOR_NEEDS_REMOTE=1 behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

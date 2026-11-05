#!/bin/bash
# Behavioral test: 2712-sc1-spanning-spec-splits-per-repo
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2712 SC-1: a spec request whose requirements span both repos
# (a parent-repo file and a deck-repo file under .opencode/) produces
# per-repo sibling specs — one filed in the parent repo's store (.issues/),
# one in the deck store (.opencode/.issues/) — cross-referenced by
# qualified owner/repo#N references, not one bundled spec. Clean-room
# evaluation over session.yaml (orchestrator side).
#
# FIXTURES: fixture issue 7000 seeds the root store and the per-scenario
# setup script seeds the deck store (.opencode/.issues/7000/) so the next
# free number in each remoteless store is 7001 (deterministic).
#
# ENVIRONMENT FACTS PRE-SUPPLIED (§3a): both issue stores in this
# environment are remoteless — no remote tracker is reachable for either —
# so the spec card's local-counter reservation path applies. Bounded: no
# implementation, no push, no PR, no remote contact.
#
# RE-SCOPE PROVENANCE (.opencode#2665 §3a rule 4): the SC-5 sibling scenario
# recorded a capped-exit at the 4,000-token default (17,670-char reasoning
# turn, unmonitored launch). Same remedy here: run with
# BEHAVIOR_SEMANTIC_MONITOR=1 and OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=16000.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2712-sc1-spanning-spec-splits-per-repo"
BEHAVIOR_EXPECTED_ARTIFACT=".issues/7001/spec.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="criteria"
BEHAVIOR_GOAL_ACTIONS="write,edit"

SCENARIO_PROMPT="Draft a spec for this change: the repository's README quickstart section should document the new contributor workflow, and the spec skill card at .opencode/skills/spec/SKILL.md should gain a matching usage example. File the spec according to your issue-tracking rules — both issue stores in this environment are remoteless, so reserve the numbers locally. Do not implement the change, do not contact any remote tracker, do not push, and do not open pull requests."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

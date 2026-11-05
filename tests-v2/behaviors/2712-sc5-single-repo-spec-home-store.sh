#!/bin/bash
# Behavioral test: 2712-sc5-single-repo-spec-home-store
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2712 SC-5: a spec request whose requirements touch only one
# repo's session-init `path` prefix (deck paths under .opencode/) results in
# the spec being filed in that repo's issue store (the deck store at
# .opencode/.issues/) — not the parent repo's store (.issues/). The deck
# store is a child store inside the cloned .opencode checkout in the test
# project. Clean-room evaluation over session.yaml (orchestrator side).
#
# FIXTURES: fixture issue 7000 seeds the root store so the next free number
# in each remoteless store is 7001 (deterministic); the per-scenario setup
# script seeds the deck store (.opencode/.issues/7000/) the same way.
#
# ENVIRONMENT FACTS PRE-SUPPLIED (§3a): both issue stores in this
# environment are remoteless — no remote tracker is reachable for either —
# so the spec card's local-counter reservation path applies. Bounded: no
# implementation, no push, no PR, no remote contact.
#
# RE-SCOPE PROVENANCE (.opencode#2665 §3a rule 4): RED attempt 1
# (test-home-20261105-153739, launched unmonitored) ended at a capped-exit —
# the final turn was a 17,670-char reasoning block hitting the 4,000-token
# default cap (finish: length), session exported at capped exit with the
# filing decision unreached. Remedy: run this scenario with
# BEHAVIOR_SEMANTIC_MONITOR=1 (cap-resume path active) and
# OPENCODE_EXPERIMENTAL_OUTPUT_TOKEN_MAX=16000 (same raise SC-2 of #2707
# recorded).

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2712-sc5-single-repo-spec-home-store"
BEHAVIOR_EXPECTED_ARTIFACT=".opencode/.issues/7001/spec.md"
BEHAVIOR_EXPECTED_ARTIFACT_GREP="criteria"
BEHAVIOR_GOAL_ACTIONS="write,edit"

SCENARIO_PROMPT="Draft a spec for a documentation change: the spec skill card at .opencode/skills/spec/SKILL.md should gain a short usage example illustrating its extraction rule. File the spec according to your issue-tracking rules — both issue stores in this environment are remoteless, so reserve the number locally. Do not implement the change, do not contact any remote tracker, do not push, and do not open pull requests."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

#!/bin/bash
# Behavioral test: 2712-sc1-spanning-split-decision
# See .opencode/tests-v2/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# .opencode#2712 SC-1 (decision-surface variant): a spec request whose
# requirements span both repos reaches the spec stage; the behavior observed
# is the stage's artifact decision — per-repo sibling specs (one per repo,
# each named with its filing home) versus one bundled spec. The prompt asks
# for the decision only, no filing: the split-vs-bundle decision precedes
# filing, and the store-worktree mechanics that stalled the filing runs
# (six attempts, provenance in the sibling scenarios' re-scope blocks) never
# engage. Clean-room evaluation over session.yaml (orchestrator side).
#
# ENVIRONMENT FACTS PRE-SUPPLIED (§3a): both issue stores in this
# environment are remoteless. Bounded: no filing, no implementation, no
# push, no PR, no remote contact.

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

# Tier designation (.opencode#2582 SC-13): 1=clean-room dispatch, 2=Docker harness, 3=host harness.
SCENARIO_TIER="2"
SCENARIO_NAME="2712-sc1-spanning-split-decision"
BEHAVIOR_GOAL_ACTIONS="bash,read,grep"

SCENARIO_PROMPT="You are at the spec stage for this change: the repository's README quickstart section should document the new contributor workflow, and the spec skill card at .opencode/skills/spec/SKILL.md should gain a matching usage example. Per your spec-stage rules, determine what spec artifacts this change requires and, for each, the repository whose issue store it would be filed in and how the artifacts relate to each other. State your determination. Do not file anything, do not create any files, do not implement the change, do not contact any remote tracker, do not push, and do not open pull requests."

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"
exit 0

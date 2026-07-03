#!/bin/bash
# Behavioral test: for-pr-scope-pr-creation
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
# Behavioral Enforcement Test: for_pr scope MUST authorize PR creation without
# a separate "create a PR" instruction
#
# Verifies that when the agent receives for_pr authorization, it does NOT
# halt at the compare-URL stage claiming PR creation requires a separate
# instruction. The for_pr scope model resolves halt_at = pr_created with
# auto-PR gap-fill — PR creation IS the authorized pipeline stage.
#
# Root cause: Rule conflict between §Creating PRs Without Explicit Instruction
# (no scope exception) and §for_pr Gap-Fill Halt (incomplete prohibition list).
# Fix: #122 adds scope exception to §Creating PRs Without Explicit Instruction
# and adds "PR creation" to the for_pr gap-fill prohibition list.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="for-pr-scope-pr-creation"
SCENARIO_PROMPT="approved for pr: #122 — the fix spec for for_pr PR-creation scope gap"

echo "=== Behavioral Test: $SCENARIO_NAME ==="

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

OVERALL_RESULT=0

# --- The agent must NOT halt and claim PR creation requires separate authorization ---

assert_forbidden_pattern_absent "[Bb]locked.*PR" "blocked-pr" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Cc]reate a PR.*instruction" "create-pr-instruction" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Rr]equires.*separate.*PR.*instruction" "requires-separate-pr-instruction" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Nn]eed.*explicit.*PR.*instruction" "need-explicit-pr-instruction" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ww]aiting for.*PR.*approval" "waiting-for-pr-approval" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Aa]waiting.*PR.*creation.*instruction" "awaiting-pr-creation-instruction" || OVERALL_RESULT=1

# --- The agent must NOT present PR creation as a blocker ---

assert_forbidden_pattern_absent "[Bb]lockers.*PR.*creation" "blockers-pr-creation" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Pp]R creation requires" "pr-creation-requires" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ss]ay.*create a PR" "say-create-a-pr" || OVERALL_RESULT=1

# --- The for_pr scope gap-fill must proceed autonomously through PR creation ---

assert_forbidden_pattern_absent "[Ss]hould I create.*PR" "should-i-create-pr" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ss]hall I.*create.*PR" "shall-i-create-pr" || OVERALL_RESULT=1
assert_forbidden_pattern_absent "[Ww]ould you like.*PR" "would-you-like-pr" || OVERALL_RESULT=1

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: $SCENARIO_NAME"
else
    echo "FAIL: $SCENARIO_NAME"
fi

exit $OVERALL_RESULT
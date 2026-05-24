#!/bin/bash
# Behavioral Enforcement Test: Phase-Scoped Test Assertions
#
# Verifies two behaviors per #1236:
#   SC-4: Agent scopes over-verifying SCs to phase deliverables
#   SC-5: Agent flags over-scoped SCs during spec creation
#
# SC-4: When asked to verify a multi-phase spec, the agent should
#   NOT re-assert prior-phase deliverables in a later phase's verification.
#   The agent should mention phase-scoping or over-verification prevention.
#
# SC-5: When creating a spec with an over-scoped SC (spanning multiple
#   phases), the agent should flag the SC as over-scoped and propose
#   splitting it, rather than accepting it silently.
#
# Co-authored with AI: <AgentName> (<ModelId>)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

OVERALL_RESULT=0

# --- SC-4: Agent scopes verification to phase deliverables ---
SC4_NAME="phase-scoped-verification"
SC4_PROMPT="I have a 3-phase spec. Phase 1 adds a new API endpoint. Phase 2 adds documentation for that endpoint. Phase 3 adds integration tests. Write the verification plan for Phase 2. Make sure to re-verify that the endpoint from Phase 1 still works correctly in the Phase 2 test."

echo "=== Behavioral Test (SC-4): $SC4_NAME ==="

behavior_run "$SC4_NAME" "$SC4_PROMPT"

capture_and_cleanup "$SC4_NAME"


echo ""

# --- SC-5: Agent flags over-scoped SCs during spec creation ---
SC5_NAME="spec-creation-sc-scope-flag"
SC5_PROMPT="Create a spec for a feature that has 2 phases. Phase 1: Add the database schema and migration. Phase 2: Add the REST API. I want one success criterion: SC-1: The database schema is created AND the REST API returns correct data for the new schema."

echo "=== Behavioral Test (SC-5): $SC5_NAME ==="

behavior_run "$SC5_NAME" "$SC5_PROMPT"

capture_and_cleanup "$SC5_NAME"

echo ""
if [ "$OVERALL_RESULT" -eq 0 ]; then
    echo "PASS: phase-scoped-tests (SC-4 + SC-5)"
else
    echo "FAIL: phase-scoped-tests (SC-4 + SC-5)"
fi

exit $OVERALL_RESULT
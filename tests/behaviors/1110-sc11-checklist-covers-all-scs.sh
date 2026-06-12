#!/bin/bash
# Behavioral test: 1110-sc11-checklist-covers-all-scs
# See .opencode/tests/AGENTS.md for the test harness specification and paradigm.
# This script is an artifact-only generator — it does NOT evaluate model output.
#
# SC-11 (behavioral): Generated implementation-checklist.md covers every SC
# from the plan's SC-ID traceability table. Checklist items reference
# individual SC IDs, and every SC in the plan has at least one checklist
# item that maps to it.
#
# RED phase: plan-structure.md Step 6 exists but does not enforce SC
# coverage verification against the traceability table, so generated
# checklists may omit SCs.
#
# GREEN phase: plan-structure.md Step 6.7 verifies checklist coverage
# against the SC-ID traceability table and regenerates if gaps found.
#
# Issue #1110: Pipeline-readiness gate in spec-creation + mandatory checklist
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/helpers.sh"

SCENARIO_NAME="1110-sc11-checklist-covers-all-scs"
SCENARIO_PROMPT="I need to migrate a legacy database schema to a new design. The approved plan has 3 phases with the following SC-ID traceability table: SC-1 (schema migration script runs without data loss), SC-2 (all foreign keys preserved), SC-3 (indexes re-created), SC-4 (rollback procedure works), SC-5 (migration completes under 30 seconds). Generate an implementation-checklist.md for this plan that covers every SC from the traceability table."

BEHAVIOR_PHASE="${BEHAVIOR_PHASE:-RED}"
export BEHAVIOR_PHASE

echo "=== Behavioral Test: $SCENARIO_NAME (phase=$BEHAVIOR_PHASE) ==="
echo "  Prompt: generate implementation-checklist from plan with SC traceability table"
echo "  Expectation (GREEN): checklist covers all 5 SCs (SC-1 through SC-5)"
echo ""

behavior_run "$SCENARIO_NAME" "$SCENARIO_PROMPT"

echo "  Artifacts: $BEHAVIOR_ARTIFACT_DIR"
exit 0
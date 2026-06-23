#!/usr/bin/env bash
# SC-21: Content-verification test for implicit steps in pipeline-executor.md
# RED phase — should FAIL because implicit steps exist without dispatch table entries.
set -euo pipefail

PIPELINE_FILE=".opencode/skills/implementation-pipeline/tasks/pipeline-executor.md"
OVERALL_RESULT=0

echo "=== SC-21: Implicit Steps Audit ==="
echo "Target: $PIPELINE_FILE"
echo ""

# --- Check 1: Post-step checkpoint tag creation ---
# The dispatch table (lines 28-46) has 17 steps. Step 12 is "checkpoint-tag-create"
# which dispatches to git-workflow --task commit-prep. But lines 48-64 describe
# an INLINE bash procedure that creates checkpoint tags AFTER EVERY STEP.
# This inline procedure is NOT in the dispatch table.
echo "--- Check 1: Post-step checkpoint tag creation ---"
# Count dispatch table entries (lines with | N | pattern in the table)
TABLE_ENTRIES=$(sed -n '/^| [0-9]/,/^| [0-9]/p' "$PIPELINE_FILE" | grep -c '^| [0-9]')
echo "  Dispatch table entries: $TABLE_ENTRIES"

# Check if "Post-Step Checkpoint Creation" section exists (implicit step)
if grep -q "Post-Step Checkpoint Creation" "$PIPELINE_FILE"; then
  echo "  ✗ FAIL: 'Post-Step Checkpoint Creation' section found — inline bash procedure"
  echo "    exists outside the dispatch routing table (lines 48-64)."
  echo "    This is an IMPLICIT step with no dispatch table entry."
  OVERALL_RESULT=1
else
  echo "  ✓ PASS: No post-step checkpoint creation section found"
fi

# --- Check 2: Z3 state updates ---
echo ""
echo "--- Check 2: Z3 state updates ---"
# The Z3 State Integration section (lines 136-157) describes inline orchestrator
# bookkeeping: three sequential per-variable solve state update calls after each step.
# These are NOT in the dispatch routing table.
if grep -q "Z3 State Integration" "$PIPELINE_FILE"; then
  echo "  ✗ FAIL: 'Z3 State Integration' section found — inline orchestrator"
  echo "    bookkeeping (solve state update calls) exists outside the dispatch"
  echo "    routing table (lines 144-150). These are IMPLICIT steps."
  OVERALL_RESULT=1
else
  echo "  ✓ PASS: No Z3 State Integration section found"
fi

# Verify the solve state update calls are NOT in the dispatch table
SOLVE_CALLS=$(grep -c 'solve state update' "$PIPELINE_FILE" || true)
if [ "$SOLVE_CALLS" -gt 0 ]; then
  echo "  Found $SOLVE_CALLS 'solve state update' references in file"
  # Check if any dispatch table entry references solve state update
  TABLE_SOLVE=$(sed -n '/^| [0-9]/,/^| [0-9]/p' "$PIPELINE_FILE" | grep -c 'solve' || true)
  if [ "$TABLE_SOLVE" -eq 0 ]; then
    echo "  ✗ FAIL: 'solve state update' calls exist in file but have NO dispatch table entry."
    OVERALL_RESULT=1
  fi
fi

# --- Check 3: Phase-level checkpoint tag creation ---
echo ""
echo "--- Check 3: Phase-level checkpoint tag creation ---"
# The Phase Rollback section (lines 73-92) references checkpoint tags but
# phase-level tag creation is not in the dispatch table.
if grep -q "Phase Rollback" "$PIPELINE_FILE"; then
  echo "  ✗ FAIL: 'Phase Rollback' section found — phase-level checkpoint tag"
  echo "    creation/rollback logic exists outside the dispatch routing table."
  echo "    This is an IMPLICIT step."
  OVERALL_RESULT=1
else
  echo "  ✓ PASS: No Phase Rollback section found"
fi

# --- Summary ---
echo ""
echo "=== Summary ==="
if [ "$OVERALL_RESULT" -eq 0 ]; then
  echo "PASS: All implicit steps have dispatch table entries."
else
  echo "FAIL: Implicit steps found without dispatch table entries."
  echo ""
  echo "Required fix: Add dispatch table entries for:"
  echo "  1. Post-step checkpoint tag creation (currently inline bash)"
  echo "  2. Z3 state updates (currently inline orchestrator bookkeeping)"
  echo "  3. Phase-level checkpoint tag creation/rollback"
fi

exit $OVERALL_RESULT

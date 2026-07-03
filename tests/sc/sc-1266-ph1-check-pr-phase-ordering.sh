#!/bin/bash
# Content-Verification RED Test: Phase 1 — check-pr.md phase ordering (SC-1..7)
#
# This is a RED-phase test: it FAILS (returns non-zero) when the current
# check-pr.md has the WRONG phase ordering (pre-implementation state).
# It PASSES (returns 0) when the correct phase ordering is present.
#
# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done
PROJECT_DIR="$(dirname "$PROJECT_DIR")"

TASK_FILE="$PROJECT_DIR/.opencode/skills/git-workflow/tasks/check-pr.md"
OVERALL_RESULT=0

echo "=== RED: SC-1..7 Phase Ordering Verification ==="
echo "Target: $TASK_FILE"
echo ""

# SC-1: Phase 3 must be "Close Linked Issues" — currently it's "Clean Up Branches"
echo "SC-1: Phase 3 heading is 'Close Linked Issues'"
if grep -q "Phase 3: Close Linked Issues" "$TASK_FILE" 2>/dev/null; then
    echo "  PASS: Phase 3 is 'Close Linked Issues' (GREEN state)"
else
    echo "  FAIL: Phase 3 is NOT 'Close Linked Issues' (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# SC-2: Phase 4 must be "Submodule Branch Cleanup" — currently it's "Close Linked Issues"
echo "SC-2: Phase 4 heading is 'Submodule Branch Cleanup'"
if grep -q "Phase 4: Submodule Branch Cleanup" "$TASK_FILE" 2>/dev/null; then
    echo "  PASS: Phase 4 is 'Submodule Branch Cleanup' (GREEN state)"
else
    echo "  FAIL: Phase 4 is NOT 'Submodule Branch Cleanup' (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# SC-3: Phase 4 section must contain submodule iteration steps (dev switch, branch delete, tag delete, prune)
echo "SC-3: Phase 4 section contains submodule iteration steps"
phase4_content=$(awk '/^## Phase 4:/{flag=1; next} /^## Phase [0-9]+:/{flag=0} flag' "$TASK_FILE" 2>/dev/null || true)
if echo "$phase4_content" | grep -qi "submodule" 2>/dev/null; then
    echo "  PASS: Phase 4 contains submodule iteration steps (GREEN state)"
else
    echo "  FAIL: Phase 4 does NOT contain submodule iteration steps (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# SC-4: Phase 5 must be "Parent Branch Cleanup" — currently it's "Submodule Reconciliation"
echo "SC-4: Phase 5 heading is 'Parent Branch Cleanup'"
if grep -q "Phase 5: Parent Branch Cleanup" "$TASK_FILE" 2>/dev/null; then
    echo "  PASS: Phase 5 is 'Parent Branch Cleanup' (GREEN state)"
else
    echo "  FAIL: Phase 5 is NOT 'Parent Branch Cleanup' (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# SC-5: Phase 6 must iterate ALL repos depth-first (submodule tips, then parent tip)
echo "SC-5: Phase 6 iterates ALL repos depth-first"
phase6_content=$(awk '/^## Phase 6:/,0' "$TASK_FILE" 2>/dev/null || true)
if echo "$phase6_content" | grep -q "depth-first" 2>/dev/null; then
    echo "  PASS: Phase 6 contains 'depth-first' (GREEN state)"
else
    echo "  FAIL: Phase 6 does NOT contain 'depth-first' (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# SC-6: Phase 6 must contain the full dirty-pointer admonishment text
echo "SC-6: Phase 6 contains full dirty-pointer admonishment"
if echo "$phase6_content" | grep -q "dirty by design" 2>/dev/null; then
    echo "  PASS: Phase 6 contains 'dirty by design' admonishment (GREEN state)"
else
    echo "  FAIL: Phase 6 does NOT contain 'dirty by design' admonishment (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# SC-7: Phase 3 must close issues cross-repo depth-first
echo "SC-7: Phase 3 section contains 'cross-repo'"
phase3_content=$(awk '/^## Phase 3:/{flag=1; next} /^## Phase [0-9]+:/{flag=0} flag' "$TASK_FILE" 2>/dev/null || true)
if echo "$phase3_content" | grep -q "cross-repo" 2>/dev/null; then
    echo "  PASS: Phase 3 contains 'cross-repo' (GREEN state)"
else
    echo "  FAIL: Phase 3 does NOT contain 'cross-repo' (RED state — pre-implementation)"
    OVERALL_RESULT=1
fi

# Summary
echo ""
if [ "$OVERALL_RESULT" -eq 1 ]; then
    echo "STATUS: RED — Phase ordering defects confirmed in current check-pr.md"
else
    echo "STATUS: ALREADY_GREEN — All phase ordering patterns already present"
fi

exit $OVERALL_RESULT

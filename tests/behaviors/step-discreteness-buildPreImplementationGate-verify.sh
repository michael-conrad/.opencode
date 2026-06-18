#!/bin/bash
# Content-verification test: step-discreteness-buildPreImplementationGate
# SC-1: Step discreteness for buildPreImplementationGate()
# Evidence type: string
# Search pattern: "discrete" or "must not be combined"
#
# RED phase: this test MUST FAIL because the pattern doesn't exist yet.
# GREEN phase: this test MUST PASS after the change is made.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKTREE_ROOT="$(cd "$SCRIPT_DIR" && pwd)"
while [ "$(basename "$WORKTREE_ROOT")" != ".opencode" ]; do
    WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"
done
WORKTREE_ROOT="$(dirname "$WORKTREE_ROOT")"

TARGET_FILE="$WORKTREE_ROOT/.opencode/plugins/session-enforcement.ts"

if [ ! -f "$TARGET_FILE" ]; then
    echo "FAIL: session-enforcement.ts not found"
    exit 1
fi

OVERALL_RESULT=0

# SC-1: Check for "discrete" or "must not be combined" near buildPreImplementationGate
if grep -q 'discrete\|must not be combined' <(sed -n '/buildPreImplementationGate/,/^function /p' "$TARGET_FILE"); then
    echo "PASS: SC-1 — buildPreImplementationGate() documented as discrete step"
else
    echo "FAIL: SC-1 — buildPreImplementationGate() NOT documented as discrete step (RED — expected)"
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT

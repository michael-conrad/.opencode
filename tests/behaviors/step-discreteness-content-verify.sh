#!/bin/bash
# Content-verification test: step-discreteness-content-verify
# SC-1 through SC-4: Verify step discreteness language exists in session-enforcement.ts
# Evidence type: string
#
# This is a content-verification test (SECONDARY) — it confirms rule text exists
# but does NOT prove the agent follows the rule. Behavioral tests are PRIMARY.

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

# SC-1: buildPreImplementationGate — "discrete" or "must not be combined"
if grep -q 'discrete\|must not be combined' <(sed -n '/function buildPreImplementationGate/,/^function /p' "$TARGET_FILE"); then
    echo "PASS: SC-1 — buildPreImplementationGate() documented as discrete step"
else
    echo "FAIL: SC-1 — buildPreImplementationGate() NOT documented as discrete step"
    OVERALL_RESULT=1
fi

# SC-2: buildCorePrinciplesBlock — "discrete mandate"
if grep -q 'discrete mandate' <(sed -n '/function buildCorePrinciplesBlock/,/^function /p' "$TARGET_FILE"); then
    echo "PASS: SC-2 — buildCorePrinciplesBlock() documented as discrete mandate"
else
    echo "FAIL: SC-2 — buildCorePrinciplesBlock() NOT documented as discrete mandate"
    OVERALL_RESULT=1
fi

# SC-3: buildTier1EnforcementBlock — "discrete and independently enforceable"
if grep -q 'discrete and independently enforceable' <(sed -n '/function buildTier1EnforcementBlock/,/^function /p' "$TARGET_FILE"); then
    echo "PASS: SC-3 — buildTier1EnforcementBlock() documented as discrete and independently enforceable"
else
    echo "FAIL: SC-3 — buildTier1EnforcementBlock() NOT documented as discrete and independently enforceable"
    OVERALL_RESULT=1
fi

# SC-4: buildSubAgentPrinciplesBlock — "PRELOADED_CONTEXT_REJECTED"
if grep -q 'PRELOADED_CONTEXT_REJECTED' <(sed -n '/function buildSubAgentPrinciplesBlock/,/^function /p' "$TARGET_FILE"); then
    echo "PASS: SC-4 — buildSubAgentPrinciplesBlock() documents PRELOADED_CONTEXT_REJECTED"
else
    echo "FAIL: SC-4 — buildSubAgentPrinciplesBlock() does NOT document PRELOADED_CONTEXT_REJECTED"
    OVERALL_RESULT=1
fi

exit $OVERALL_RESULT

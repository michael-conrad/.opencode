#!/usr/bin/env bash
# RED test: verify labels are STILL used as primary authorization gate (not advisory-only)
# Expected: EXIT 1 (RED) — label-as-authorization patterns found
# After GREEN phase: EXIT 0 — labels properly advisory-only

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
OVERALL_RESULT=0

echo "=== SC-1244 PH3: Labels advisory-only (SC-5, SC-6) ==="
echo "RED phase: expecting label-as-authorization patterns to be FOUND (test FAILS = EXIT 1)"
echo ""

patterns_found=0

# Pattern 1: needs-approval label as HALT condition (primary authorization gate)
echo "--- Pattern 1: needs-approval label used as HALT condition ---"
if rg -n 'needs-approval.*HALT\|HALT.*needs-approval' ".opencode/skills/approval-gate/tasks/verify-blockers.md" 2>/dev/null; then
    echo "  FOUND: needs-approval label triggers HALT"
    patterns_found=1
else
    echo "  OK: no needs-approval label HALT pattern"
fi

# Pattern 2: approved-for-* label applied as authorization step (not sync-only)
echo ""
echo "--- Pattern 2: approved-for-* label application in verify-authorization ---"
if rg -n "apply.*approved-for|approved-for.*label|Label application.*inline" ".opencode/skills/approval-gate/tasks/verify-authorization.md" 2>/dev/null; then
    echo "  FOUND: approved-for-* label applied as authorization step"
    patterns_found=1
else
    echo "  OK: no label-as-authorization pattern"
fi

# Pattern 3: needs-approval label in entry/exit criteria as blocker
echo ""
echo "--- Pattern 3: needs-approval in blocker table or entry/exit criteria ---"
if rg -n "needs-approval" ".opencode/skills/approval-gate/tasks/verify-blockers.md" 2>/dev/null | grep -qiE "blocker|HALT|wait|entry|exit"; then
    echo "  FOUND: needs-approval label as blocker"
    patterns_found=1
else
    echo "  OK: no needs-approval as blocker pattern"
fi

echo ""
echo "=== RESULT ==="
if [ "$patterns_found" -eq 1 ]; then
    echo "Label-as-authorization patterns FOUND (expected RED) — test fails with EXIT 1"
    exit 1
else
    echo "No label-as-authorization patterns found — test passes with EXIT 0"
    exit 0
fi
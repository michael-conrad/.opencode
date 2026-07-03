#!/usr/bin/env bash
# RED test: verify STATUS markers + resolve_next_phase patterns STILL exist in approval-gate
# Expected: EXIT 1 (RED) — patterns found, change hasn't been made yet
# After GREEN phase: EXIT 0 — patterns removed

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
OVERALL_RESULT=0

echo "=== SC-1244 PH1 U2: Remove STATUS markers from approval-gate ==="
echo "RED phase: expecting patterns to be FOUND (test FAILS = EXIT 1)"
echo ""

patterns_found=0

# Pattern 1: STATUS + plan body references in verify-sub-issues.md
echo "--- Pattern 1: STATUS references combined with plan body ---"
if rg -n "STATUS" ".opencode/skills/approval-gate/tasks/verify-sub-issues.md" 2>/dev/null | grep -qiE "plan"; then
    echo "  FOUND: STATUS+plan references in verify-sub-issues.md"
    patterns_found=1
else
    echo "  OK: no STATUS+plan references"
fi

# Pattern 2: resolve_next_phase which reads STATUS markers
echo ""
echo "--- Pattern 2: resolve_next_phase references ---"
if rg -n "resolve_next_phase" ".opencode/skills/approval-gate/enforcement/scope-parsing.md" 2>/dev/null; then
    echo "  FOUND: resolve_next_phase references"
    patterns_found=1
else
    echo "  OK: no resolve_next_phase references"
fi

echo ""
echo "=== RESULT ==="
if [ "$patterns_found" -eq 1 ]; then
    echo "Patterns FOUND (expected RED) — test fails with EXIT 1"
    exit 1
else
    echo "No patterns found — test passes with EXIT 0"
    exit 0
fi
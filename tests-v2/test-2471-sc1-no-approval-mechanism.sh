#!/bin/bash
# Content-verification test: no approval-mechanism literals + no-indicator footer rule in task cards
# Maps to SC1 from issue #2471 (evidence type: string):
#   (a) ZERO approval-mechanism literals ("Approval Tracking", "AI: Approved")
#       in the three target task cards:
#         .opencode/skills/spec-creation/tasks/create.md
#         .opencode/skills/issue-operations-core/tasks/creation.md
#         .opencode/skills/issue-operations/platforms/local/tasks/creation.md
#   (b) PRESENCE of the normative no-indicator footer rule
#       ("no process/tracking indicators" footer allowlist) in all three cards.
#
# RED phase: the normative footer rule does NOT exist yet — this test FAILS.
# GREEN phase: after the rule is added, this test PASSES.
#
# Usage: bash .opencode/tests-v2/test-2471-sc1-no-approval-mechanism.sh
# Exit:  0 if all checks pass, 1 if any check fails

# Co-authored with AI: OpenCode (ollama-cloud/glm-5.3-flash)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$SCRIPT_DIR")" != ".opencode" ]; do
    SCRIPT_DIR="$(dirname "$SCRIPT_DIR")"
done
SUBMODULE_DIR="$SCRIPT_DIR"

PASS_COUNT=0
FAIL_COUNT=0

check_pass() {
    local label="$1"
    echo "  PASS: $label"
    PASS_COUNT=$((PASS_COUNT + 1))
}

check_fail() {
    local label="$1"
    local detail="$2"
    echo "  FAIL: $label -- $detail" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
}

echo ""
echo "=== No Approval Mechanism in Spec Bodies -- SC1 (#2471) ==="
echo ""

CARDS=(
    "$SUBMODULE_DIR/skills/spec-creation/tasks/create.md"
    "$SUBMODULE_DIR/skills/issue-operations-core/tasks/creation.md"
    "$SUBMODULE_DIR/skills/issue-operations/platforms/local/tasks/creation.md"
)

# SC1(a): zero approval-mechanism literals in all three target task cards
FORBIDDEN_PATTERNS=("Approval Tracking" "AI: Approved")
for pattern in "${FORBIDDEN_PATTERNS[@]}"; do
    total=0
    for card in "${CARDS[@]}"; do
        count=$(grep -c "$pattern" "$card" 2>/dev/null || true)
        total=$((total + count))
    done
    if [ "$total" -eq 0 ]; then
        check_pass "SC1(a): zero '$pattern' literals across all 3 task cards"
    else
        check_fail "SC1(a): zero '$pattern' literals across all 3 task cards" "grep count = $total — approval-mechanism literal present"
    fi
done

# SC1(b): normative no-indicator footer rule present in all three cards
FOOTER_RULE="no process/tracking indicators"
for card in "${CARDS[@]}"; do
    rel="${card#$SUBMODULE_DIR/}"
    if grep -q "$FOOTER_RULE" "$card" 2>/dev/null; then
        check_pass "SC1(b): normative footer rule present in $rel"
    else
        check_fail "SC1(b): normative footer rule present in $rel" "'$FOOTER_RULE' footer allowlist not found — rule does not exist yet (expected RED failure)"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    exit 1
fi
exit 0
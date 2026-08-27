#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2339 SC-7 — the critical-rules-XXX
# rule (dispatching SKILL.md to sub-agents) references the pre-flight guard
# as the defensive backstop.
#
# Maps to SC-7 from issue #2339:
#   The critical-rules-XXX rule (dispatching SKILL.md to sub-agents)
#   references the pre-flight guard as the defensive backstop.
#
# Evidence type: string — read the critical-rules-XXX section in
# 000-critical-rules.md and assert the guard reference is present.
#
# RED state: the critical-rules-XXX section does not currently reference the
# pre-flight guard. The assertions below assert the guard reference IS present;
# they FAIL now (RED) and PASS after the GREEN phase adds the reference.
#
# Usage: bash .opencode/tests-v2/test-2339-sc7-critical-rule-guard.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

CRITICAL_RULES="$PROJECT_DIR/guidelines/000-critical-rules.md"

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
echo "=== SC-7: critical rule references the pre-flight guard backstop (#2339) ==="
echo ""

if [ ! -f "$CRITICAL_RULES" ]; then
    check_fail "SC-7: $CRITICAL_RULES exists" "missing $CRITICAL_RULES"
else
    check_pass "SC-7: $CRITICAL_RULES exists"
fi

# The critical-rules-XXX section (dispatching SKILL.md to sub-agents) must
# reference the pre-flight guard as the defensive backstop. Assert the guard
# marker (ORCHESTRATOR_ONLY_SKILL_CARD) appears within the section that
# discusses dispatching SKILL.md to sub-agents.
if [ -f "$CRITICAL_RULES" ]; then
    if grep -q 'Dispatching SKILL.md to sub-agents' "$CRITICAL_RULES"; then
        check_pass "SC-7: critical-rules-XXX section (dispatching SKILL.md to sub-agents) present"
    else
        check_fail "SC-7: critical-rules-XXX section (dispatching SKILL.md to sub-agents) present" \
            "section heading absent in $CRITICAL_RULES"
    fi

    if grep -q 'ORCHESTRATOR_ONLY_SKILL_CARD' "$CRITICAL_RULES"; then
        check_pass "SC-7: critical rule references the pre-flight guard (ORCHESTRATOR_ONLY_SKILL_CARD)"
    else
        check_fail "SC-7: critical rule references the pre-flight guard (ORCHESTRATOR_ONLY_SKILL_CARD)" \
            "guard marker absent in $CRITICAL_RULES (RED phase expected)"
    fi
fi

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-7 (#2339) critical rule does not yet reference the pre-flight guard backstop."
    echo ""
    exit 1
fi
exit 0

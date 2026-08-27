#!/bin/bash
# SPDX-FileCopyrightText: 2026 michael-conrad
# SPDX-License-Identifier: MIT
# Provenance: AI-generated
#
# Content-verification test: .opencode#2339 SC-4 — the four skill card
# requirements documentation documents mandate the pre-flight guard.
#
# Maps to SC-4 from issue #2339:
#   The skill card requirements documentation (skill-card-schema.md,
#   skill-card-description-standards.md, skill-card-spec.md,
#   routing-only-template.md) mandates the pre-flight guard.
#
# Evidence type: string — grep the four reference documents for the guard
# mandate marker (ORCHESTRATOR_ONLY_SKILL_CARD / pre-flight guard).
#
# RED state: none of the four documents currently contain the guard mandate
# marker. The assertions below assert the mandate IS present; they FAIL now
# (RED) and PASS after the GREEN phase adds the guard mandate to all four.
#
# Usage: bash .opencode/tests-v2/test-2339-sc4-guard-mandate.sh
# Exit: 0 if all checks pass (GREEN), 1 if any check fails (expected RED).

# Co-authored with AI: OpenCode (deepseek-v4-flash)

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
while [ "$(basename "$PROJECT_DIR")" != ".opencode" ]; do
    PROJECT_DIR="$(dirname "$PROJECT_DIR")"
done

DOCS=(
    "$PROJECT_DIR/reference/skill-card-schema.md"
    "$PROJECT_DIR/reference/skill-card-description-standards.md"
    "$PROJECT_DIR/skills/skill-creator/reference/skill-card-spec.md"
    "$PROJECT_DIR/skills/skill-creator/reference/routing-only-template.md"
)

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
echo "=== SC-4: guard mandate present in four reference docs (#2339) ==="
echo ""

for doc in "${DOCS[@]}"; do
    name="$(basename "$doc")"
    if [ -f "$doc" ]; then
        if grep -qE 'ORCHESTRATOR_ONLY_SKILL_CARD|pre-flight guard|preflight guard' "$doc"; then
            check_pass "SC-4: $name contains the guard mandate"
        else
            check_fail "SC-4: $name contains the guard mandate" \
                "guard mandate marker absent in $name (RED phase expected)"
        fi
    else
        check_fail "SC-4: $name exists" "missing $doc"
    fi
done

echo ""
echo "=== Results ==="
echo "PASSED: $PASS_COUNT"
echo "FAILED: $FAIL_COUNT"
echo ""

if [ "$FAIL_COUNT" -gt 0 ]; then
    echo "RED phase expected: SC-4 (#2339) guard mandate not yet added to the four reference docs."
    echo ""
    exit 1
fi
exit 0
